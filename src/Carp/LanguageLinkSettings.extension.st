Extension { #name : #LanguageLinkSettings }

{ #category : #'*Carp' }
LanguageLinkSettings class >> carpDefaultSettings [

	^ self new 
		clientSocketAddress: (LanguageLinkSocketAddress 
				ipOrName: 'localhost' port: (9000 + 99 atRandom));
		serverSocketAddress: (LanguageLinkSocketAddress 
				ipOrName: 'localhost' port: (9900 + 99 atRandom));
		messageBrokerStrategy: LanguageLinkHttpMessageBroker;
		serverProcessClass: JSLinkPharoNodejsProcess;
		platform: JSLinkPharoPlatform new;
		commandFactoryClass: JSLinkCommandFactory;
		commandClass: LanguageLinkCommand;
		serializerClass: LanguageLinkSerializer;
		deserializerClass: JSLinkDeserializer;
		parserClass: CarpParser;
		yourself
]
