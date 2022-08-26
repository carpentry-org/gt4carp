Extension { #name : #LanguageLinkSettings }

{ #category : #'*Carp' }
LanguageLinkSettings class >> carpDefaultSettings [

	^ self new 
		clientSocketAddress: (LanguageLinkSocketAddress 
				ipOrName: 'localhost' port: (9000 + 99 atRandom));
		serverSocketAddress: (LanguageLinkSocketAddress 
				ipOrName: 'localhost' port: (9900 + 99 atRandom));
		messageBrokerStrategy: LanguageLinkHttpMessageBroker;
		serverProcessClass: CarpPythonProcess;
		platform: CarpPlatform new;
		commandFactoryClass: CarpCommandFactory;
		commandClass: CarpCommand;
		serializerClass: LanguageLinkSerializer;
		deserializerClass: CarpDeserializer;
		parserClass: CarpParser;
		yourself
]
