/** Reno Tracks, Copyright 2012, 2013 Hack4Reno
 *
 *   @author Brad.Hellyar <bradhellyar@gmail.com>
 *
 *   Updated/Modified for Reno, Nevada app deployment. Based on the
 *   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Reno Tracks.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <MapKit/MapKit.h>


@class LoadingView;
@class NoteViewController;
@class Note;
@class NoteManager;

@interface SavedNotesViewController : UITableViewController
    <UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    NSMutableArray *notes;
    NoteManager *noteManager; 
    NSManagedObjectContext *managedObjectContext;
    LoadingView *loading;
    NSInteger pickerCategory;
    Note * selectedNote;
}

@property (nonatomic, strong) NSMutableArray *notes;
@property (nonatomic, strong) NoteManager *noteManager;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Note *selectedNote;

- (void)initNoteManager:(NoteManager*)manager;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext*)context NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNoteManager:(NoteManager*)manager NS_DESIGNATED_INITIALIZER;

- (void)displayUploadedNote;

@end
