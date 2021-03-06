# A job to submit reports and run in background
class ReportJob < ActiveJob::Base
  queue_as :default

  # The method used to run the report by rails.
  def perform(*reports)
    reports.each do |report|
      begin
        run_report(report)
      rescue => e
        report.update_attributes status: 'error'
        raise e
      end
    end
  end

  # Run the individual report
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def run_report(report)
    report.update! status: 'running'

    klass = report.name.constantize

    r = klass.new(report.parameters)
    if r.parameters_valid?
      record_set = r.query
      report_template = klass.template

      output = ApplicationController.new
                                    .render_to_string(template: report_template, formats: report.format,
                                                      locals: { klass: klass, record_set: record_set,
                                                                created_at: report.created_at })
      report.update! status: 'completed', output: output
    else
      report.update_attributes status: 'error'
      report.update_attributes status_message: r.error_message
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
