//
//  XMLConverter.m
//  bbcfeedreader
//
//  Created by Zabolotnyy S. on 05.08.15.
//  Copyright (c) 2015 Zabolotnyy S. All rights reserved.
//

#import "XMLConverter.h"

@interface XMLConverter () <NSXMLParserDelegate>

@end


@implementation XMLConverter
{
    NSMutableArray *fDictionaryStack;
    NSMutableString *fTextInProgress;
    NSError *fErrorPointer;
}

#pragma mark - public

+ (NSDictionary *)qd_dictionaryForXMLData:(NSData *)data error:(NSError **)error
{
    XMLConverter *reader = [[XMLConverter alloc] initWithError:error];
    NSDictionary *rootDictionary = [reader objectWithData:data];

    return rootDictionary;
}

#pragma mark - lifecycle

- (id)initWithError:(NSError **)error
{
    if (self = [super init])
    {
        fErrorPointer = *error;
    }
    return self;
}

#pragma mark - private

- (NSDictionary *)objectWithData:(NSData *)data
{
    fDictionaryStack = [NSMutableArray new];
    fTextInProgress  = [NSMutableString new];
    
    // Initialize the stack with a fresh dictionary
    [fDictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    // Return the stack’s root dictionary on success
    if (success)
    {
        NSDictionary *resultDict = [fDictionaryStack objectAtIndex:0];
        return resultDict;
    }
    
    return nil;
}

#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [fDictionaryStack lastObject];
    
    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there's already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn't exist
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [fDictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [fDictionaryStack lastObject];
    
    // Set the text property
    if ([fTextInProgress length] > 0)
    {
        // trim after concatenating
        NSString *trimmedString = [fTextInProgress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [dictInProgress setObject:[trimmedString mutableCopy] forKey:@"value"];
        
        // Reset the text
        fTextInProgress = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [fDictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
    [fTextInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser’s error object
    fErrorPointer = parseError;
}



@end
