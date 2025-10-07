import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {

    let filenameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter filename (e.g., example.txt)"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let downloadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Download", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    let statusLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Status: Idle"
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    let progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.progress = 0.0
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    var downloadTask: URLSessionDownloadTask?
    var session: URLSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(filenameField)
        view.addSubview(downloadButton)
        view.addSubview(progressView)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            filenameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            filenameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filenameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            downloadButton.topAnchor.constraint(equalTo: filenameField.bottomAnchor, constant: 20),
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            progressView.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
    }

    @objc func downloadTapped() {
        guard let filename = filenameField.text, !filename.isEmpty else {
            statusLabel.text = "Status: Enter a filename!"
            return
        }

        let ftpUrl = URL(string: "ftp://user:12345@127.0.0.1:2121/\(filename)")!
        let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

        statusLabel.text = "Status: Downloading..."
        progressView.progress = 0.0

        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        downloadTask = session?.downloadTask(with: ftpUrl)
        downloadTask?.resume()
    }

    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            progressView.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let filename = filenameField.text else { return }
        let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        try? FileManager.default.moveItem(at: location, to: destination)
        statusLabel.text = "Status: Downloaded \(filename) to Documents"
        progressView.progress = 1.0
    }
}
