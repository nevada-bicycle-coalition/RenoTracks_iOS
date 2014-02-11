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

//
//  UIImageViewResizable.h
//
//  Created by Mike Valstar on 2012-09-10.
//

#import <UIKit/UIKit.h>

@interface UIImageViewResizable : UIImageView <UIGestureRecognizerDelegate>{
    UIPanGestureRecognizer *panGesture;
}

@property(nonatomic) BOOL isZoomable;

- (void) applyGestures;
- (void) scaleToMinimum;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;
- (void)pan:(UIPanGestureRecognizer *)gesture;
- (void)doubleTap:(UITapGestureRecognizer *)gesture;

@end