require "rspec/core/formatters/html_formatter"

# Rspec HTML Formatter
# Run it via:
#    rspec --require ./spec/rspec_html_formatter.rb --format RspecHtmlFormatter spec/ > specs.html
#

class RspecHtmlFormatter < RSpec::Core::Formatters::HtmlFormatter
  def initialize(output)
    super(output)
  end

  def jira_url(req_no)
  	"http://jira/browse/#{req_no}"
  end

  def example_passed(example)
    @printer.move_progress(percent_done)
    req_id = example.options[:req]

    formatted_run_time = sprintf("%.5f", example.execution_result[:run_time])
    @output.puts "<dd class=\"example passed\"><span class=\"passed_spec_name\">#{example.description}</span><a href=\"#{jira_url('#{req_id}')}\"> #{req_id}</a><span class='duration'>#{formatted_run_time}s</span></dd>"
    @printer.flush
  end
end