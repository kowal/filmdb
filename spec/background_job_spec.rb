# coding: utf-8

require 'spec_helper'

describe MoviesReport::BackgroundJob do

  it 'saves jobs under incremented job-id numbers' do
    @job = MoviesReport::BackgroundJob.new(%w{ 001 002 009 })
    job_id = @job.save

    expect(job_id).not_to be_nil
    expect{ job_id = @job.save }.to change{job_id}
  end

end
