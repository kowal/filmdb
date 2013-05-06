require "rspec/core/formatters/html_formatter"

# Rspec HTML Formatter
# Run it via:
#    rspec --require ./spec/support/rspec_html_formatter.rb --format RspecHtmlFormatter spec/ > specs.html
#
RSpec.configure do |c|
  c.add_setting :project_tracker_url
end

class RspecHtmlFormatter < RSpec::Core::Formatters::HtmlFormatter

  def initialize(output)
    super(output)
    @project_tracker_url = RSpec.configuration.project_tracker_url

    ensure_valid_config!
  end

  def req_url(req_no)
    @project_tracker_url % req_no
  end

  def example_passed(example)
    @printer.move_progress(percent_done)
    @output.puts(html_for_example(example))
    @printer.flush
  end

  private

  def formatted_example_run_time(example)
     sprintf("%.5f", example.execution_result[:run_time])
  end

  def requirements_links(example)
    requirements_ids = Array(example.options[:req])
    description = example.options[:desc]

    create_requirement_link = ->(req_id) { html_for_requirement_link(description, req_id) }

    requirements_ids.map(&create_requirement_link).join(' ')
  end

  def html_for_example(example)
    <<-HTML
      <dd class="example passed">
       <span class="passed_spec_name">#{example.description}</span>
       #{requirements_links(example)}
       <span class="duration">#{formatted_run_time(example)}s</span>
      </dd>
    HTML
  end

  def html_for_requirement_link(description, req_id)
    "<a title='#{description}' href='#{req_url(req_id)}'>#{req_id}</a>"
  end

  def ensure_valid_config!
    unless @project_tracker_url
      puts 'Please set up :project_tracker_url in your rspec config!'
      # exit
    end
  end
end