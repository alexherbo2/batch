require "spec"
require "yaml"

path = File.join(ENV["PWD"], "bin")
ENV["PATH"] = path + ":" + ENV["PATH"]

describe "Batch" do
  Dir.cd("spec/examples") do
    examples = Dir.glob("*")
    examples.each do |example|
      Dir.cd(example) do
        describe example do
          stdin = File.new("stdin")
          stdout = IO::Memory.new
          stderr = IO::Memory.new
          # Arguments
          arguments = [] of String
          if File.exists? "arguments.yml"
            string = File.read("arguments.yml")
            arguments = Array(String).from_yaml(string)
          end
          # Expected exit status
          expected_status = 0
          if File.exists? "status"
            expected_status = File.read("status").to_i
          end
          # Expected stdout
          expected_stdout = ""
          if File.exists? "stdout"
            expected_stdout = File.read("stdout")
          end
          # Expected stderr
          expected_stderr = ""
          if File.exists? "stderr"
            expected_stderr = File.read("stderr")
          end
          status = Process.run(
            command: "batch",
            args: ["--no-confirm", "--editor", %(cp file "${@}")] + arguments,
            input: stdin,
            output: stdout,
            error: stderr
          )
          it "correctly exits" do
            status.exit_code.should eq expected_status
          end
          it "correctly outputs to stdout" do
            stdout.to_s.should eq expected_stdout
          end
          it "correctly outputs to stderr" do
            stderr.to_s.should eq expected_stderr
          end
        end
      end
    end
  end
end
