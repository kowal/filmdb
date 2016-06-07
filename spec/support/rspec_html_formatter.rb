# coding: utf-8

require 'rspec/core/formatters/html_formatter'

# Rspec HTML Formatter
# Run it via:
#    rspec --require ./spec/support/rspec_html_formatter.rb
#          --format RspecHtmlFormatter spec/ > specs.html
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

  def start(_example_count)
    @output.puts HTML_HEADER
    @output.puts REPORT_HEADER
  end

  def req_url(req_no)
    @project_tracker_url % req_no
  end

  def example_passed(example)
    @output.puts(html_for_example(example))
    @printer.flush
  end

  def dump_summary(_duration, example_count, _failure_count, _pending_count)
    insert_html '#totals', "Sumary. Example_count : #{example_count}"

    @printer.flush
  end

  def example_group_started(example_group)
    @example_group_red = false
    @example_group_number += 1

    @printer.print_example_group_end if example_group_number != 1
    @printer.print_example_group_start(example_group_number, example_group.description, example_group.parent_groups.size)
    @output.puts "<div class='indent level#{example_group.parent_groups.size}'></div>"
    @printer.flush
  end

  def insert_html(selector, content)
    @output.puts "<script type=\"text/javascript\">$('#{selector}').html(\"#{content}\");</script>"
  end

  private

  def formatted_example_run_time(example)
    sprintf('%.5f', example.execution_result[:run_time])
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
      </dd>
    HTML
  end

  def html_for_requirement_link(description, req_id)
    "<a title='#{description}' class='btn btn-mini' href='#{req_url(req_id)}'>#{req_id}</a>"
  end

  def ensure_valid_config!
    return if @project_tracker_url

    puts 'Please set up :project_tracker_url in your rspec config!'
    exit
  end
end
