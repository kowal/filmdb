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
  	"http://localhost/jira/browse/#{req_no}"
  end

  def example_passed(example)
    @printer.move_progress(percent_done)
    @output.puts(example_html(example))
    @printer.flush
  end

  private

  def example_html(example)
    <<-HTML
      <dd class="example passed">
       <span class="passed_spec_name">#{example.description}</span>
       #{requirements_links(example)}
       <span class="duration">#{formatted_run_time(example)}s</span>
      </dd>
    HTML
  end

  def formatted_example_run_time(example)
     sprintf("%.5f", example.execution_result[:run_time])
  end

  def requirements_links(example)
    requirements_ids = Array(example.options[:req])
    create_requirement_link = ->(req_id) { "<a href='#{jira_url(req_id)}'>#{req_id}</a>" }

    requirements_ids.map(&create_requirement_link).join(' ')
  end

end