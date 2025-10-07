import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {

    // Text fields for IP, port, and filename
    let ipField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter IP (default: 192.168.0.138)"
        tf.text = "192.168.0.138"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let portField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Port (default: 2121)"
        tf.text = "2121"
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let filenameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter filename (default: readme.txt)"
        tf.text = "readme.txt"
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

        // Add all subviews
        view.addSubview(ipField)
        view.addSubview(portField)
        view.addSubview(filenameField)
        view.addSubview(downloadButton)
        view.addSubview(progressView)
        view.addSubview(statusLabel)

        // Layout
        NSLayoutConstraint.activate([
            ipField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            ipField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ipField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            portField.topAnchor.constraint(equalTo: ipField.bottomAnchor, constant: 15),
            portField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            portField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            filenameField.topAnchor.constraint(equalTo: portField.bottomAnchor, constant: 15),
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
        // Use defaults if fields are empty
        let ip = ipField.text?.isEmpty == false ? ipField.text! : "192.168.0.138"
        let port = portField.text?.isEmpty == false ? portField.text! : "2121"
        let filename = filenameField.text?.isEmpty == false ? filenameField.text! : "readme.txt"

        guard let portInt = Int(port) else {
            statusLabel.text = "Status: Invalid port!"
            return
        }

        let ftpUrlString = "ftp://user:12345@\(ip):\(portInt)/\(filename)"
        guard let ftpUrl = URL(string: ftpUrlString) else {
            statusLabel.text = "Status: Invalid URL!"
            return
        }

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
        let filename = filenameField.text?.isEmpty == false ? filenameField.text! : "readme.txt"
        let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

        try? FileManager.default.moveItem(at: location, to: destination)
        statusLabel.text = "Status: Downloaded \(filename) to Documents"
        progressView.progress = 1.0
    }
}
