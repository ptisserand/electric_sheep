module ElectricSheep
  module Commands
    module Compression
      class TarGz
        include ElectricSheep::Command
        include DeleteSource

        register as: 'tar_gz'

        def perform!
          logger.info "Compressing #{input.path} to #{input.basename}.tar.gz"
          file_resource(host, extension: '.tar.gz').tap do |archive|
            compress!(input_path, archive)
          end
        end

        private

        def input_path
          shell.safe(shell.expand_path(input.path))
        end

        def compress!(input_path, archive)
          shell.exec cmd(input_path, archive)
          delete_source! input_path
        end

        def cmd(input_path, archive)
          cmd = "cd #{File.dirname(input_path)}; "
          cmd << "tar -cvzf #{shell.safe(shell.expand_path(archive.path))} "
          cmd << "#{File.basename(input_path)} 1>&2"
        end
      end
    end
  end
end
