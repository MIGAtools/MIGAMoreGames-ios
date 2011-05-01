//
//  MIGAMoreGamesContentValidation.h
//  MIGAMoreGames
//
//  Created by Darryl H. Thomas on 8/18/10.
//  Copyright 2010 Mobile Independent Gaming Alliance. All rights reserved.
//

#import <Foundation/Foundation.h>

BOOL MIGAMoreGamesContentValidationValidateContentObject(id contentObject);

BOOL MIGAMoreGamesContentValidationRequireDictionary(const id object, const NSString *errorMessage);

BOOL MIGAMoreGamesContentValidationRequireDictionaryKeyExists(const NSDictionary *dictionary, id key, const NSString *errorMessage);

BOOL MIGAMoreGamesContentValidationRequireArray(const id object, const NSString *errorMessage);

BOOL MIGAMoreGamesContentValidationRequireString(const id object, const NSString *errorMessage);

BOOL MIGAMoreGamesContentValidationTest(const BOOL test, const NSString *errorMessage);

BOOL MIGAMoreGamesContentValidationRequireObjectRespondsToSelector(const id object, const SEL selector, const NSString *errorMessage);