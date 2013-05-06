// LimeChat is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the terms of the GPL version 2 (see the file GPL.txt).

#import "ChannelDialog.h"
#import "NSWindowHelper.h"
#import "NSStringHelper.h"


@implementation ChannelDialog

@synthesize delegate;
@synthesize window;
@synthesize parentWindow;
@synthesize uid;
@synthesize cid;
@synthesize config;

- (id)init
{
    self = [super init];
    if (self) {
        [NSBundle loadNibNamed:@"ChannelDialog" owner:self];
        
        keywords = [NSMutableArray new];
        excludeWords = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
    [keywords release];
    [excludeWords release];
    
    keywordsTable.delegate = nil;
    keywordsTable.dataSource = nil;
    
    excludeWordsTable.delegate = nil;
    excludeWordsTable.dataSource = nil;

    [window release];
    [config release];
    [super dealloc];
}

- (void)start
{
    isSheet = NO;
    isEndedSheet = NO;
    [self load];
    [self update];
    [self show];
}

- (void)startSheet
{
    isSheet = YES;
    isEndedSheet = NO;
    [self load];
    [self update];
    [NSApp beginSheet:window modalForWindow:parentWindow modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)show
{
    if (![self.window isVisible]) {
        [self.window centerOfWindow:parentWindow];
    }
    [self.window makeKeyAndOrderFront:nil];
}

- (void)close
{
    delegate = nil;
    [self.window close];
}

- (void)sheetDidEnd:(NSWindow*)sender returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    isEndedSheet = YES;
    [window close];
}

- (void)load
{
    nameText.stringValue = config.name;
    passwordText.stringValue = config.password;
    modeText.stringValue = config.mode;
    topicText.stringValue = config.topic;

    autoJoinCheck.state = config.autoJoin;
    consoleCheck.state = config.logToConsole;
    growlCheck.state = config.growl;
    
    [keywords setArray:config.keywords];
    [excludeWords setArray:config.excludeWords];
    
    [keywordsTable reloadData];
    [excludeWordsTable reloadData];
}

- (void)save
{
    config.name = nameText.stringValue;
    config.password = passwordText.stringValue;
    config.mode = modeText.stringValue;
    config.topic = topicText.stringValue;

    config.autoJoin = autoJoinCheck.state;
    config.logToConsole = consoleCheck.state;
    config.growl = growlCheck.state;
    
    [config.keywords setArray:keywords];
    [config.excludeWords setArray:excludeWords];
    
    if (![config.name isChannelName]) {
        config.name = [@"#" stringByAppendingString:config.name];
    }
}

- (void)update
{
    if (cid < 0) {
        [self.window setTitle:@"New Channel"];
    }
    else {
        [nameText setEditable:NO];
        [nameText setSelectable:NO];
        [nameText setBezeled:NO];
        [nameText setDrawsBackground:NO];
    }

    NSString* s = nameText.stringValue;
    [okButton setEnabled:s.length > 0];
}

- (void)controlTextDidChange:(NSNotification*)note
{
    [self update];
}

- (void)addNewWord:(ListView*)table
{
    NSMutableArray* list = [self listForTable:table];
    
    [list addObject:@""];
    [table reloadData];
    int row = list.count - 1;
    [table selectItemAtIndex:row];
    [table editColumn:0 row:row withEvent:nil select:YES];
}

- (void)removeSelectedWord:(ListView*)table
{
    NSMutableArray* list = [self listForTable:table];
    
    NSInteger n = [table selectedRow];
    if (n >= 0) {
        [list removeObjectAtIndex:n];
        [table reloadData];
        int count = list.count;
        if (count <= n) n = count - 1;
        if (n >= 0) {
            [table selectItemAtIndex:n];
        }
    }
}

- (NSMutableArray*)listForTable:(NSTableView*) table
{
    NSMutableArray* returnList;
    returnList = table == keywordsTable ? keywords : excludeWords;
    return returnList;
}

#pragma mark -
#pragma mark Actions

- (void)ok:(id)sender
{
    [self save];

    if ([delegate respondsToSelector:@selector(channelDialogOnOK:)]) {
        [delegate channelDialogOnOK:self];
    }

    [self cancel:nil];
}

- (void)cancel:(id)sender
{
    if (isSheet) {
        [NSApp endSheet:window];
    }
    else {
        [self.window close];
    }
}

- (IBAction)onAddKeyword:(id)sender
{
    [self addNewWord:keywordsTable];
}

- (IBAction)onAddExcludeWord:(id)sender
{
    [self addNewWord:excludeWordsTable];
}

- (IBAction)onRemoveKeyword:(id)sender
{
    [self removeSelectedWord:keywordsTable];
}

- (IBAction)onRemoveExcludeWord:(id)sender
{
    [self removeSelectedWord:excludeWordsTable];
}

#pragma mark -
#pragma mark NSTableView Delegate

- (void)textDidEndEditing:(NSNotification*)note
{
    ListView* table;
    
    if ([keywordsTable editedRow] >= 0)
        table = keywordsTable;
    else if ([excludeWordsTable editedRow] >= 0)
        table = excludeWordsTable;
    else
        return;
    
    NSInteger n = [table editedRow];
    NSString* s = [[[[[note object] textStorage] string] copy] autorelease];
    [[self listForTable:table] replaceObjectAtIndex:n withObject:s];
    [table reloadData];
    [table selectItemAtIndex:n];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)sender
{
    NSMutableArray* list = [self listForTable:sender];
    NSInteger count = [list count];
    return count;
}

- (id)tableView:(NSTableView *)sender objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    return [[self listForTable:sender] objectAtIndex:row];
}

#pragma mark -
#pragma mark NSWindow Delegate

- (void)windowWillClose:(NSNotification*)note
{
    if (isSheet && !isEndedSheet) {
        [NSApp endSheet:window];
    }

    if ([delegate respondsToSelector:@selector(channelDialogWillClose:)]) {
        [delegate channelDialogWillClose:self];
    }
}

@end
