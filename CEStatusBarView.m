/*
=================================================
CEStatusBarView
(for CotEditor)

 Copyright (C) 2004-2007 nakamuxu.
 Copyright (C) 2014 CotEditor Project
 http://coteditor.github.io
=================================================

encoding="UTF-8"
Created:2005.03.30

------------
This class is based on JSDTextView (written by James S. Derry – http://www.balthisar.com)
JSDTextView is released as public domain.
arranged by nakamuxu, Dec 2004.
-------------------------------------------------

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA. 


=================================================
*/

#import "CEStatusBarView.h"
#import "CEEditorView.h"
#import "constants.h"


@interface CEStatusBarView ()

@property (nonatomic, retain, readwrite) NSTextField *leftTextField;
@property (nonatomic, retain, readwrite) NSTextField *rightTextField;

@property (nonatomic, retain) NSImageView *readOnlyView;

@end


//------------------------------------------------------------------------------------------



#pragma mark -

@implementation CEStatusBarView

@synthesize showStatusBar = _showStatusBar;


#pragma mark Public Methods

//=======================================================
// Public method
//
//=======================================================

// ------------------------------------------------------
- (id)initWithFrame:(NSRect)frameRect
// 初期化
// ------------------------------------------------------
{
    self = [super initWithFrame:frameRect];
    if (self) {
        id values = [[NSUserDefaultsController sharedUserDefaultsController] values];

        // setup TextField
        CGFloat fontSize = (CGFloat)[[values valueForKey:k_key_statusBarFontSize] doubleValue] ? : 11.0;
        NSFont *font = [NSFont controlContentFontOfSize:fontSize];
        
        NSRect textFieldFrame = frameRect;
        textFieldFrame.origin.x += k_statusBarReadOnlyWidth;
        textFieldFrame.origin.y -= (k_statusBarHeight - [font pointSize]) / 4;
        textFieldFrame.size.width -= [NSScroller scrollerWidth] + k_statusBarReadOnlyWidth + k_statusBarRightPadding;
        
        [self setLeftTextField:[[NSTextField allocWithZone:[self zone]] initWithFrame:textFieldFrame]]; // ===== alloc
        [[self leftTextField] setEditable:NO];
        [[self leftTextField] setSelectable:NO];
        [[self leftTextField] setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [[self leftTextField] setFont:font];
        [[self leftTextField] setBordered:NO];
        [[self leftTextField] setDrawsBackground:NO];
        [[self leftTextField] setAlignment:NSLeftTextAlignment];

        [self setRightTextField:[[NSTextField allocWithZone:[self zone]] initWithFrame:textFieldFrame]]; // ===== alloc
        [[self rightTextField] setEditable:NO];
        [[self rightTextField] setSelectable:NO];
        [[self rightTextField] setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [[self rightTextField] setFont:font];
        [[self rightTextField] setBordered:NO];
        [[self rightTextField] setDrawsBackground:NO];
        [[self rightTextField] setAlignment:NSRightTextAlignment];

        // setup ReadOnly icon
        NSRect readOnlyFrame = frameRect;
        readOnlyFrame.size.width = k_statusBarReadOnlyWidth;
        [self setReadOnlyView:[[NSImageView allocWithZone:[self zone]] initWithFrame:readOnlyFrame]]; // ===== alloc
        [[self readOnlyView] setAutoresizingMask:NSViewHeightSizable];

        [self setShowsReadOnlyIcon:NO];
        [self setAutoresizingMask:NSViewWidthSizable];
        
        [self addSubview:[self leftTextField]];
        [self addSubview:[self rightTextField]];
        [self addSubview:[self readOnlyView]];
    }
    return self;
}


// ------------------------------------------------------
- (void)dealloc
// 後片付け
// ------------------------------------------------------
{
    // _masterView is not retain.
    [[self leftTextField] release];
    [[self rightTextField] release];
    [[self readOnlyView] release];

    [super dealloc];
}


// ------------------------------------------------------
- (BOOL)showStatusBar
// ステータスバーを表示するかどうかを返す
// ------------------------------------------------------
{
    return _showStatusBar;
}


// ------------------------------------------------------
- (void)setShowStatusBar:(BOOL)showStatusBar
// ステータスバー表示の有無をセット
// ------------------------------------------------------
{
    if (showStatusBar != _showStatusBar) {
        _showStatusBar = showStatusBar;

        CGFloat height = [self showStatusBar] ? k_statusBarHeight : 0.0;
        [self setHeight:height];
    }
}


// ------------------------------------------------------
- (void)setShowsReadOnlyIcon:(BOOL)showsReadOnlyIcon
// "ReadOnly"アイコン表示の有無をセット
// ------------------------------------------------------
{
    if (showsReadOnlyIcon) {
        [[self readOnlyView] setImage:[NSImage imageNamed:@"lockOnImg"]];
        [[self readOnlyView] setToolTip:NSLocalizedString(@"This Document is ReadOnly", nil)];
    } else {
        [[self readOnlyView] setImage:nil];
        [[self readOnlyView] setToolTip:nil];
    }
}


// ------------------------------------------------------
- (void)drawRect:(NSRect)dirtyRect
// 矩形を描画
// ------------------------------------------------------
{
    if (![self masterView] || ![self showStatusBar]) {
        return;
    }
    
    // fill in background
    [[NSColor windowBackgroundColor] set];
    [NSBezierPath fillRect:dirtyRect];
    
    // draw frame border (only top line)
    [[NSColor controlShadowColor] set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX([self frame]), NSMaxY([self frame]) - 0.5)
                              toPoint:NSMakePoint(NSMaxX([self frame]), NSMaxY([self frame]) - 0.5)];
}



#pragma mark -
#pragma mark Private Methods

// ------------------------------------------------------
- (void)setHeight:(CGFloat)height
// 高さをセット
// ------------------------------------------------------
{
    CGFloat adjHeight = height - NSHeight([self frame]);
    NSRect newFrame;

    // set masterView height
    newFrame = [[[self masterView] splitView] frame];
    newFrame.origin.y += adjHeight;
    newFrame.size.height -= adjHeight;
    [[[self masterView] splitView] setFrame:newFrame];
    
    // set statusBar height
    newFrame = [self frame];
    newFrame.size.height += adjHeight;
    [self setFrame:newFrame];

    [[[self window] contentView] setNeedsDisplay:YES];
}

@end
