class Static
  attr_reader :app, :root, :file_handler

  def initialize(app)
    @app = app
    @root = :public
    @file_handler = FileHandler.new(root)
  end

  def call(env)
    req = Rack::Request.new(env)
    path = req.path

    if path.index("/#{root}")
      res = file_handler.call(env)
    else
      res = app.call(env)
    end

    res
  end
end

class FileHandler
  MIME_TYPES = {
    ".txt" => "text/plain",
    ".jpg" => "image/jpeg",
    ".zip" => "application/zip"
  }

  def initialize(root)
    @root = root
  end

  def call(env)
    res = Rack::Response.new
    file_name = requested_file(env)

    if File.exist?(file_name)
      serve_file(file_name, res)
    else
      res.status = 404
      res.write("File not found")
    end

    res
  end

  private

  def requested_file(env)
    req = Rack::Request.new(env)
    path = req.path
    directory = File.dirname(__FILE__)
    File.join(directory, "..", path)
  end

  def serve_file(file_name, res)
    extension = File.extname(file_name)
    content_type = MIME_TYPES[extension]
    file = File.read(file_name)
    res["Content-type"] = content_type
    res.write(file)
  end
end
