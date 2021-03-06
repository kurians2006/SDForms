//
//  SDItemSelectionFormField.m
//  SDForms
//
//  Created by Rafal Kwiatkowski on 25.08.2014.
//  Copyright (c) 2014 Snowdog sp. z o.o. All rights reserved.
//

#import "SDItemSelectionField.h"
#import "SDFormItemsPickerViewController.h"
#import "SDLabelFormCell.h"
#import "NSMutableArray+IndexSelection.h"


@interface SDItemSelectionField () <SDItemsPickerViewControllerDelegate>

@end

@implementation SDItemSelectionField

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


- (NSArray *)reuseIdentifiers {
    return @[kLabelCell];
}

- (NSArray *)cellHeights {
    return @[@44.0];
}

- (SDFormCell *)cellForTableView:(UITableView *)tableView atIndex:(NSUInteger)index
{
    SDFormCell *cell = [super cellForTableView:tableView atIndex:index];
    
    if ([cell isKindOfClass:[SDLabelFormCell class]]) {
        SDLabelFormCell *labelCell = (SDLabelFormCell *)cell;
        labelCell.titleLabel.text = self.title;
        labelCell.valueLabel.text = self.formattedValue;
    }
    
    if (self.presentingMode == SDFormFieldPresentingModePush) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString *)formattedValue
{
    if (self.formatDelegate && [self.formatDelegate respondsToSelector:@selector(formattedValueForField:)]) {
        return [self.formatDelegate formattedValueForField:self];
    } else {
        NSString *title = @"";
        if (self.selectedIndexes.count > 0) {
            NSInteger i = 0;
            for (NSNumber *number in self.selectedIndexes) {
                NSString *item = [self.items objectAtIndex:number.integerValue];
                if (i > 0) {
                    title = [NSString stringWithFormat:@"%@, %@", title, item];
                } else {
                    title = item;
                }
                i++;
            }
        }
        return title;
    }
}

- (void)setItems:(NSArray *)items
{
    _items = items;
}

- (void)setSelectedIndexes:(NSMutableArray *)selectedIndexes
{
    for (NSNumber *index in selectedIndexes) {
        NSAssert(self.items.count > 0 && (index.integerValue >= 0 && index.integerValue < self.items.count), @"Selected index %@ beyond bounds of items array (%ld)", index, self.items.count);
    }
    
    _selectedIndexes = selectedIndexes;
}

- (NSMutableArray *)selectedIndexes
{
    if (!_selectedIndexes) {
        _selectedIndexes = [[NSMutableArray alloc] init];
    }
    return _selectedIndexes;
}

- (void)form:(SDForm *)form didSelectFieldAtIndex:(NSInteger)index
{
    if (index == 0) {
        SDFormItemsPickerViewController *controller = [[SDFormItemsPickerViewController alloc] init];
        controller.delegate = self;
        controller.items = self.items;
        controller.selectedIndexes = self.selectedIndexes;
        controller.multiChoice = self.multiChoice;
        [self presentViewController:controller animated:YES];
    }
}

- (void)itemsPickerViewController:(SDFormItemsPickerViewController *)controller didDeselectElementAtIndex:(NSInteger)index
{
    [self.selectedIndexes deselectIndex:index];
    [self refreshFieldCell];
}

- (void)itemsPickerViewController:(SDFormItemsPickerViewController *)controller didSelectElementAtIndex:(NSInteger)index
{
    [self.selectedIndexes selectIndex:index];
    [self refreshFieldCell];
}

@synthesize selectedIndexes = _selectedIndexes;

@end
