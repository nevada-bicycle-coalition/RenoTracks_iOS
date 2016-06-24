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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "NoteManager.h"
#import "TripManager.h"
#import "TripPurposeDelegate.h"

@interface NoteViewController : UIViewController <MKMapViewDelegate>
{
    id <TripPurposeDelegate> delegate;
    IBOutlet MKMapView *noteView;
    Note *note;
    UIBarButtonItem *doneButton;
	UIBarButtonItem *flipButton;
	UIView *infoView;
}

@property (nonatomic, strong) id <TripPurposeDelegate> delegate;
@property (nonatomic, strong) Note *note;
@property (nonatomic ,strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *flipButton;
@property (nonatomic, strong) UIView *infoView;

-(instancetype)initWithNote:(Note *)note NS_DESIGNATED_INITIALIZER;

@end
