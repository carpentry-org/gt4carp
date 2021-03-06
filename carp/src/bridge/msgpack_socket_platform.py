import msgpack
import socket
import _thread
import threading
import time
import sys
import bridge.globals
from bridge import stoppable_thread, msgpack_serializer
from uuid import uuid1

# Messages supported by this sockets must be Dictionaries. This is because we use special key __sync to know if it is 
# a synchronized message or not. If it is we hook a semaphore to that id under the __sync key and after we receive the 
# value we store there the return message and signal the semaphore.
class MsgPackSocketPlatform:

    def __init__(self, port):
        self.port = port
        self.client = None
        self.serializer = msgpack_serializer.MsgPackSerializer()
        self.unpacker = msgpack.Unpacker(raw=False)
        self.packer = msgpack.Packer(use_bin_type=True)
        self.sync_table = {}
        self.async_handlers = {}
    
    def addMapping(self, key_type, mapping_function):
        msgpack_serializer.addMapping(key_type, mapping_function)

    def set_handler(self, msg_type, async_handler):
        self.async_handlers[msg_type] = async_handler

    def prim_handle(self):
        try:
            bridge.globals.logger.log("loop func")
            data = self.client.recv(2048)
            if len(data) == 0:
                time.sleep(0.005)
            else:
                self.unpacker.feed(data)
                for msg in self.unpacker:
                    bridge.globals.logger.log("prim handle message")
                    self.prim_handle_msg(msg)
        except OSError:
            bridge.globals.logger.log("OSError: " + str(err))
            self.stop()
            sys.exit()
            exit(-1)
        except Exception as err:
            bridge.globals.logger.log("ERROR message: " + str(err))

    def setup_func(self):
        self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.client.connect(('localhost', self.port))

    def stop(self):
        if self.thread is not None:
            self.thread.stop()
        if self.client is not None:
            self.client.close()
            self.client = None

    def send_answer(self, msg, answer):
        if answer['type'] != msg['type']:
            raise Exception('Type mismatch')
        answer['__sync'] = msg['__sync']
        self.send_async_message(answer)
    
    def is_running(self):
        return self.client != None
    
    def prim_handle_msg(self, raw_msg):
        msg = raw_msg
        msg_type = msg['type'] 
        if msg_type in self.async_handlers:
            self.async_handlers[msg['type']](msg)
        elif is_sync_msg(msg):
            sync_id = message_sync_id(msg)
            semaphore = self.sync_table[sync_id]
            self.sync_table[sync_id] = msg
            semaphore.release()
        else:
            bridge.globals.logger.log("Error! Msg couldnt be handled")
            raise Exception('Message couldn''t be handled')
        
    
    def start(self):
        self.thread = stoppable_thread.StoppableThread(
            loop_func= self.prim_handle,
            setup_func= self.setup_func)
        self.thread.start()
        time.sleep(.1)

    def send_async_message(self, msg):
        self.client.send(self.packer.pack(msg))
    
    def send_sync_message(self, msg):
        sync_id = mark_message_as_sync(msg)
        semaphore = threading.Semaphore(value=0)
        self.sync_table[sync_id] = semaphore
        self.send_async_message(msg)
        semaphore.acquire()
        ans = self.sync_table[sync_id]
        del self.sync_table[sync_id]
        return ans

def is_sync_msg(msg):
    return '__sync' in msg
    
def message_sync_id(msg):
    return msg['__sync']
    
def mark_message_as_sync(msg):
    sync_id = uuid1().hex
    msg['__sync'] = sync_id
    return sync_id

def build_service(port, pharo_port, feed_callback):
    service = MsgPackSocketPlatform(pharo_port)
    service.set_handler('ENQUEUE',feed_callback)
    service.set_handler('IS_ALIVE', lambda msg: service.send_answer(msg, {'type': 'IS_ALIVE'}))
    return service
