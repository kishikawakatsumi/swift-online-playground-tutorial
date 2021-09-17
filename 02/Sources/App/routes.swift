import Vapor

func routes(_ app: Application) throws {
    app.get { (req) in
        req.eventLoop.makeSucceededFuture(
            req.fileio.streamFile(at: "\(app.directory.publicDirectory)/index.html")
        )
    }
    
    app.post("run") { (req) -> Response in
        let parameter = try req.content.decode(RequestParameter.self)
        let tempFile = "\(NSTemporaryDirectory())main.swift"
        try parameter.code.write(
            toFile: tempFile,
            atomically: false,
            encoding: .utf8
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = [tempFile]

        let standardOutput = Pipe()
        process.standardOutput = standardOutput

        process.launch()
        process.waitUntilExit()

        let output = standardOutput.fileHandleForReading.readDataToEndOfFile()
        guard let result = String(data: output, encoding: .utf8) else { throw Abort(.internalServerError) }
        return Response(output: result)
    }
}

struct RequestParameter: Decodable {
    let code: String
}

struct Response: Content {
    let output: String
}
