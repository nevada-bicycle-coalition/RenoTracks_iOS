/** Reno Tracks, Copyright 2012, 2013 Hack4Reno
 *
 *   @author Brad.Hellyar <bradhellyar@gmail.com>
 *
 *   Updated/Modified for Reno, Nevada app deployment. Based on the
 *   CycleTracks codebase for SFCTA, and the Atlanta Cycle app repo.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Cycle Atlanta.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TripPurposeDelegate.h"

@interface TripDetailViewController : UIViewController<UINavigationControllerDelegate, UITextViewDelegate>
{
    id <TripPurposeDelegate> delegate;
    UITextView *detailTextView;
    NSInteger pickerCategory;
    NSString *details;
}

@property (nonatomic, retain) id <TripPurposeDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextView *detailTextView;


-(IBAction)skip:(id)sender;
-(IBAction)saveDetail:(id)sender;

@end
