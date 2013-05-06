// LimeChat is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the terms of the GPL version 2 (see the file GPL.txt).

#import <Cocoa/Cocoa.h>


@interface ListView : NSTableView
{
    IBOutlet __weak id keyDelegate;
    IBOutlet __weak id textDelegate;
}

@property (nonatomic, weak) id keyDelegate;
@property (nonatomic, weak) id textDelegate;

- (int)countSelectedRows;
- (void)selectItemAtIndex:(int)index;
- (void)selectRows:(NSArray*)indices;
- (void)selectRows:(NSArray*)indices extendSelection:(BOOL)extend;

@end


@interface NSObject (ListViewDelegate)
- (void)listViewDelete;
- (void)listViewMoveUp;
- (void)listViewKeyDown:(NSEvent*)e;
@end
