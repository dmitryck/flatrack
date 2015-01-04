class Flatrack
  # Helps to build sample sites for specs
  module SiteHelper
    extend FileUtils
    include FileUtils

    DIR = File.join Flatrack.gem_root, '../tmp/flatrack-sites'
    mkdir_p DIR

    def site(clean: true, &block)
      sha = SecureRandom.hex
      in_temp_sites do
        create_site(sha, &block)
      end
      clean ? cleanup(sha) : sha
    rescue => error
      cleanup sha
      raise error
    end

    def in_temp_sites
      Dir.chdir DIR do
        yield
      end
    end

    def write(type, filename, contents)
      Dir.chdir(type.to_s.pluralize) do
        File.open(filename, 'w') do |file|
          file.write(contents)
        end
      end
    end

    def get_page_response(page)
      url = URI.parse 'http://example.org'
      url.path = File.join '', page
      env = Rack::MockRequest.env_for url.to_s
      Flatrack::Site.call(env)
    end

    private

    def create_site(sha)
      Flatrack::CLI.start(
        ['new', sha, '--verbose', 'false', '--bundle', 'false']
      )
      Dir.chdir(sha) do
        yield
      end
    end

    def cleanup(sha)
      Dir.chdir(DIR) do
        rmtree sha
      end
    end
  end
end
