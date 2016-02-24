//
//  ViewController.h
//  ImageScroll demo
//
//  Created by Gennadi Iosad on 24/02/2016.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController() <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation ViewController

#pragma mark -
#pragma mark UIViewController overrides
#pragma mark -

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.scrollView.delegate = self;
  [self.scrollView addGestureRecognizer:[self doubleTapGestureRecognizer]];
  
  UIImage *img = [UIImage imageNamed:@"pocketwatch0878"]; //from http://www.freeimages.co.uk/galleries/objects/watch/slides/pocketwatch0878.htm
  [self showImage:img];
  
  NSLog(@"ViewController::viewDidLoad");
}


-(UITapGestureRecognizer *) doubleTapGestureRecognizer {
  UITapGestureRecognizer *doubleTapRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(scrollViewDoubleFingerTapped:)];
  doubleTapRecognizer.numberOfTapsRequired = 2;
  doubleTapRecognizer.numberOfTouchesRequired = 1;
  return doubleTapRecognizer;

}


- (void)scrollViewDoubleFingerTapped:(UITapGestureRecognizer*)recognizer {
  //if already zoomed out - zoom in a bit
  if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
    [self.scrollView setZoomScale:self.scrollView.zoomScale*2 animated:YES];
  } else { //zoom out
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
  }
}


- (void)viewDidLayoutSubviews {
  NSLog(@"DetailsPhotoViewController::viewDidLayoutSubviews");
  [super viewDidLayoutSubviews];
  
  if (self.imageView) {
    [self aspectFitImage];
  }
}

#pragma mark -
#pragma mark UIScrollViewDelegate impl
#pragma mark -

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return self.imageView;
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
  // The scroll view has zoomed, so you need to re-center the contents
  [self centerScrollViewContents];
}

#pragma mark -
#pragma mark aux logic
#pragma mark -


- (void) showImage:(UIImage *)image {
  self.imageView = [[UIImageView alloc] initWithImage:image];
  [self.scrollView addSubview:self.imageView];
  self.scrollView.contentSize = self.imageView.bounds.size;
}


- (void)centerScrollViewContents {
  CGSize scrollViewSize = [self scrollViewVisibleSize];
  // First assume that image center coincides with the contents box center.
  // This is correct when the image is bigger than scrollView due to zoom
  CGPoint imageCenter = CGPointMake(self.scrollView.contentSize.width/2.0,
                                    self.scrollView.contentSize.height/2.0);
  
  CGPoint scrollViewCenter = [self scrollViewCenter];
  
  //if image is smaller than the scrollView visible size - fix the image center accordingly
  if (self.scrollView.contentSize.width < scrollViewSize.width) {
    imageCenter.x = scrollViewCenter.x;
  }
  
  if (self.scrollView.contentSize.height < scrollViewSize.height) {
    imageCenter.y = scrollViewCenter.y;
  }
  
  self.imageView.center = imageCenter;
}


- (void)aspectFitImage {
  CGSize scrollViewSize = [self scrollViewVisibleSize];
  CGSize imageSize = CGRectStandardize(self.imageView.bounds).size;
  
  CGFloat scaleWidth = scrollViewSize.width / imageSize.width;
  CGFloat scaleHeight = scrollViewSize.height / imageSize.height;
  
  //set the zoom scale so all the image fits the screen
  self.scrollView.minimumZoomScale = MIN(scaleWidth, scaleHeight);
  self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
  self.scrollView.maximumZoomScale = 3;
  
  //start zoomed out and centered
  [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
  
  self.imageView.center = [self scrollViewCenter];
}


//return the scroll view center
- (CGPoint)scrollViewCenter {
  CGSize scrollViewSize = [self scrollViewVisibleSize];
  return CGPointMake(scrollViewSize.width/2.0, scrollViewSize.height/2.0);
}


// Return scrollview size without the area overlapping with tab and nav bar.
- (CGSize) scrollViewVisibleSize {
  UIEdgeInsets contentInset = self.scrollView.contentInset;
  CGSize scrollViewSize = CGRectStandardize(self.scrollView.bounds).size;
  CGFloat width = scrollViewSize.width - contentInset.left - contentInset.right;
  CGFloat height = scrollViewSize.height - contentInset.top - contentInset.bottom;
  return CGSizeMake(width, height);
}

@end

NS_ASSUME_NONNULL_END
