from flask import Flask, request
import http.client
import argparse
import sys
import traceback
import bridge.globals

def serialize(obj):
	return bridge.globals.msg_service.serializer.serialize(obj)

def deserialize(text):
	return bridge.globals.msg_service.serializer.deserialize(text)

def observer(commandId, observerId):
	return lambda obj: notify_observer(obj, commandId, observerId)

#### NOTIFICATION FUNCTIONS
def notify(obj, notificationId):
	bridge.globals.logger.log("PYTHON: Notify " + str(notificationId))
	data = {}
	data["type"] = "EVAL"
	data["id"] = notificationId
	data["value"] = serialize(obj)
	bridge.globals.msg_service.send_async_message(data)

def notify_observer(obj, commandId, observerId):
	bridge.globals.logger.log("PYTHON: Notify observer " + str(commandId) + " " + str(observerId))
	data = {}
	data["type"] = "CALLBACK"
	data["commandId"] = commandId
	data["observerId"] = observerId
	data["value"] = serialize(obj)
	rawValue = bridge.globals.msg_service.send_sync_message(data)['value']
	return deserialize(rawValue)

def notify_error(ex, command):
	bridge.globals.logger.log("Error on command: " + str(command.command_id()))
	bridge.globals.logger.log("Exception: " + str(ex))
	data = {}
	data["type"] = "ERR"
	data["errMsg"] = str(ex)
	data["trace"] = traceback.format_exc(100)
	data["commandId"] = command.command_id()
	return bridge.globals.msg_service.send_sync_message(data)

def bridge_inspect(obj):
	if hasattr(obj,'__dict__'):
		return obj.__dict__
	else:
		return {}
