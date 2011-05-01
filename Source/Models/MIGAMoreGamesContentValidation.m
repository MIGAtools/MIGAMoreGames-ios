//
//  MIGAMoreGamesContentValidation.m
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 8/18/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import "MIGAMoreGamesContentValidation.h"
#import "MIGALogging.h"

BOOL MIGAMoreGamesContentValidationValidateContentObject(id contentObject)
{
	
	id field = nil;
	BOOL result = MIGAMoreGamesContentValidationRequireDictionary(contentObject, @"Content root is not a dictionary.");
	
	if (!result)
		return NO;
	
	NSDictionary *contentDictionary = (NSDictionary *)contentObject;
	result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(contentDictionary, @"version", @"Version field is missing.") && MIGAMoreGamesContentValidationTest([[contentDictionary objectForKey: @"version"] intValue] == 1, @"Unsupported content version specified.");
	
	if (!result)
		return NO;
	
	if ((field = [contentDictionary objectForKey: @"expire_at"]) != nil) {
		result = MIGAMoreGamesContentValidationRequireObjectRespondsToSelector(field, @selector(doubleValue), @"expire_at field does not respond to doubleValue");
		
		if (!result)
			return NO;
	}
	
	if ((field = [contentDictionary objectForKey: @"purge_at"]) != nil) {
		result = MIGAMoreGamesContentValidationRequireObjectRespondsToSelector(field, @selector(doubleValue), @"purge_at field does not respond to doubleValue");
		
		if (!result)
			return NO;
	}
	
	result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(contentDictionary,  @"apps", @"apps field missing.") && (field = [contentDictionary objectForKey: @"apps"]) && MIGAMoreGamesContentValidationRequireArray(field,  @"apps field is not an array.");
	
	if (!result)
		return NO;
	
	NSArray *apps = (NSArray *)field;
	for (field in apps) {
		result = MIGAMoreGamesContentValidationRequireDictionary(field, @"apps item is not a dictionary");
		
		if (!result)
			return NO;
		
		NSDictionary *app = (NSDictionary *)field;
		result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(app, @"content_id", @"app is missing content id") && (field = [app objectForKey: @"content_id"]) && MIGAMoreGamesContentValidationRequireObjectRespondsToSelector(field,  @selector(intValue),  @"content_id field does not respond to intValue");
		
		if (!result)
			return NO;
		
		result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(app, @"click_url",  @"app is missing click url") && (field = [app objectForKey: @"click_url"]) && MIGAMoreGamesContentValidationRequireString(field, @"app click_url field is not a string.");
		
		if (!result)
			return NO;
		
		result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(app, @"title",  @"app is missing title") && (field = [app objectForKey: @"title"]) && MIGAMoreGamesContentValidationRequireString(field, @"app title field is not a string.");
		
		if (!result)
			return NO;
		
		result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(app, @"detail",  @"app is missing detail") && (field = [app objectForKey: @"detail"]) && MIGAMoreGamesContentValidationRequireString(field, @"app detail field is not a string.");
		
		if (!result)
			return NO;
		
		result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(app, @"package",  @"app is missing package") && (field = [app objectForKey: @"package"]) && MIGAMoreGamesContentValidationRequireString(field, @"app package field is not a string.");
		
		if (!result)
			return NO;
		
		result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(app, @"publisher",  @"app is missing publisher") && (field = [app objectForKey: @"publisher"]) && MIGAMoreGamesContentValidationRequireString(field, @"app publisher field is not a string.");
		
		if (!result)
			return NO;
		
		if ((field = [app objectForKey: @"price"])) {
			result = MIGAMoreGamesContentValidationRequireString(field, @"app price field is not a string.");
			
			if (!result)
				return NO;
		}		
		
		result = MIGAMoreGamesContentValidationRequireDictionaryKeyExists(app, @"images",  @"app is missing images") && (field = [app objectForKey: @"images"]) && (MIGAMoreGamesContentValidationRequireDictionary(field, @"app images field is not a dictionary.") || (MIGAMoreGamesContentValidationRequireArray(field, @"app images is not an array") && [(NSArray *)field count] == 0));
		
		if (!result)
			return NO;
		
		if ([field isKindOfClass: [NSDictionary class]]) {
			NSDictionary *images = (NSDictionary *)field;
			for (NSString *imageKey in [images allKeys]) {
				field = [images objectForKey: imageKey];
				result = MIGAMoreGamesContentValidationRequireString(field,  [NSString stringWithFormat: @"app image with key %@ is not a string", imageKey]);
				
				if (!result)
					return NO;
			}
		}
		
	}
	
	return YES;	
}

BOOL MIGAMoreGamesContentValidationRequireDictionary(const id object, const NSString *errorMessage)
{
	if (![object isKindOfClass: [NSDictionary class]]) {
		MIGADLog(@"%@", errorMessage);
		return NO;
	}
	
	return YES;
}

BOOL MIGAMoreGamesContentValidationRequireDictionaryKeyExists(const NSDictionary *dictionary, id key, const NSString *errorMessage)
{
	if ([dictionary objectForKey: key] == nil) {
		MIGADLog(@"%@", errorMessage);
		return NO;
	}
	
	return YES;
}

BOOL MIGAMoreGamesContentValidationRequireArray(const id object, const NSString *errorMessage)
{
	if (![object isKindOfClass: [NSArray class]]) {
		MIGADLog(@"%@", errorMessage);
		return NO;
	}
	
	return YES;
}

BOOL MIGAMoreGamesContentValidationRequireString(const id object, const NSString *errorMessage)
{
	if (![object isKindOfClass: [NSString class]]) {
		MIGADLog(@"%@", errorMessage);
		return NO;
	}
	
	return YES;
}

BOOL MIGAMoreGamesContentValidationTest(const BOOL test, const NSString *errorMessage)
{
	if (!test) {
		MIGADLog(@"%@", errorMessage);
		return NO;
	}
	
	return YES;
}

BOOL MIGAMoreGamesContentValidationRequireObjectRespondsToSelector(const id object, const SEL selector, const NSString *errorMessage)
{
	if (![object respondsToSelector: selector]) {
		MIGADLog(@"%@", errorMessage);
		return NO;
	}
	
	return YES;
}
