#import "ViewController.h"

@interface ViewController () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) UITextField *filenameField;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // Filename field
    self.filenameField = [[UITextField alloc] init];
    self.filenameField.placeholder = @"Enter filename (e.g., example.txt)";
    self.filenameField.borderStyle = UITextBorderStyleRoundedRect;
    self.filenameField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.filenameField];

    // Download button
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    self.downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.downloadButton addTarget:self action:@selector(downloadTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];

    // Progress view
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progress = 0.0;
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.progressView];

    // Status label
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.text = @"Status: Idle";
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];

    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.filenameField.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:50],
        [self.filenameField.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.filenameField.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [self.downloadButton.topAnchor constraintEqualToAnchor:self.filenameField.bottomAnchor constant:20],
        [self.downloadButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [self.progressView.topAnchor constraintEqualToAnchor:self.downloadButton.bottomAnchor constant:20],
        [self.progressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        [self.statusLabel.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor constant:20],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

// Download action
- (void)downloadTapped {
    NSString *filename = self.filenameField.text;
    if (filename.length == 0) {
        self.statusLabel.text = @"Status: Enter a filename!";
        return;
    }

    NSString *ftpURLString = [NSString stringWithFormat:@"ftp://user:12345@127.0.0.1:2121/%@", filename];
    NSURL *ftpURL = [NSURL URLWithString:ftpURLString];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    self.downloadTask = [self.session downloadTaskWithURL:ftpURL];
    [self.downloadTask resume];

    self.statusLabel.text = @"Status: Downloading...";
    self.progressView.progress = 0.0;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (totalBytesExpectedToWrite > 0) {
        self.progressView.progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSString *filename = self.filenameField.text;
    NSURL *destination = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:filename];

    [[NSFileManager defaultManager] moveItemAtURL:location toURL:destination error:nil];
    self.statusLabel.text = [NSString stringWithFormat:@"Status: Downloaded %@ to Documents", filename];
    self.progressView.progress = 1.0;
}

@end
