#!/bin/ruby

require File.expand_path("../pulse/lib/pulse", __FILE__)

page = Pulse::Page.define do |c|
  c.project  = 'Film DB'
  c.github   = 'kowal/filmdb'
  c.branch   = 'add-sidekiq' # `git rev-parse --abbrev-ref HEAD`.chop
  c.badges   = [
    # built-in:
    :travis,
    :gemnasium,
    :coveralls,
    :codeclimate,
    :pullreview,
    # custom:
    [
      'CodeShip',
      'https://www.codeship.io/projects/4462',
      'https://www.codeship.io/projects/6b44c0d0-a7cb-0131-488a-1a410b9a7696/status?branch=master'
    ]
  ]
  c.specs    = 'specs.html'
  c.coverage = 'coverage/index.html'
  c.metrics  = 'tmp/metric_fu/output/index.html'
  c.tasks = {
    'Setup gems'                => 'bundle',
    'Setup system dependencies' => './setup.sh',
    'Preview Pulse Page'        => './pulse.sh',
    'Run tests'         => 'rspec',
    'Run metrics'       => 'metric_fu',
    'Preview README'    => 'yield',
    'Start all systems' => 'foreman start'
  }
  c.reports = {
    'Specs Summary'  => ['specs.html'],
    'Specs Coverage' => ['coverage/index.html'],
    'Code Metrics'   => ['tmp/metric_fu/output/index.html'],
    'Issues'         => ['https://mkowalcze.kanbanery.com/projects/32672/board/', 'warning']
  }
end

page.build 'index.html'
