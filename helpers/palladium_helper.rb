# frozen_string_literal: true

require 'palladium'
class PalladiumHelper
  def initialize(plan_name, run_name)
    @palladium = Palladium.new(host: StaticData::PALLADIUM_SERVER,
                               token: StaticData.get_palladium_token,
                               product: StaticData::PROJECT_NAME,
                               plan: plan_name,
                               run: run_name)
  end

  def get_result_set_link
    "http://#{@palladium.host}/product/"\
    "#{@palladium.product_id}/plan/"\
    "#{@palladium.plan_id}/run/"\
    "#{@palladium.run_id}/result_set/"\
    "#{@palladium.result_set_id}"
  end

  def add_result_and_log(example, file_data = nil, server_response = nil)
    result = add_result(example, file_data, server_response)
    OnlyofficeLoggerHelper.log("Test is #{result['status']['name']}")
    OnlyofficeLoggerHelper.log(get_result_set_link)
  end

  def add_result(example, file_data = nil, server_response = nil)
    name = example.metadata[:description]
    status, comment = get_status_detailed_comment(example, file_data, parse_server_response(server_response))
    @palladium.set_result(name: name, description: comment, status: status)
  end

  # Adds additional information about the file size
  # @param
  #   example [Hash] rspec data
  #   file_data [Integer] Image size
  # @note Information can be added using the new element of the "subdescriber" array.
  # @example status, comment = get_status_detailed_comment(example, file_data)
  # @return
  #   [status] test status
  #   [comment.to_json] comment about test status and image size or server responce
  def get_status_detailed_comment(example, image_size = nil, server_response = nil)
    status, comment = get_status(example)
    if image_size
      comment = { describer: [{ title: 'comment', value: comment }] }
      comment[:subdescriber] = [{ title: 'image size (byte)', value: image_size }]
    elsif server_response
      comment = { describer: [{ title: 'comment', value: comment }] }
      comment[:subdescriber] = [{ title: 'server error:', value: server_response }]
    end
    [status, comment.to_json]
  end

  def get_result_sets(status)
    @palladium.get_result_sets(status).map { |set| set['name'] }
  end

  def get_status(example)
    exception = example.exception
    comment = ''
    return [:pending, example.metadata[:execution_result].pending_message] if example.pending

    # custom_fields = init_custom_fields(example)
    if exception.to_s.include?('got:') || exception.to_s.include?('expected:')
      result = :failed
      comment += "\n#{exception.to_s.gsub('got:', "got:\n").gsub('expected:', "expected:\n")}\n"
    elsif exception.to_s.include?('to return') || exception.to_s.include?('expected')
      result = :failed
      comment += "\n#{exception.to_s.gsub('to return ', "to return:\n").gsub(', got ', "\ngot:\n")}"
    elsif exception.nil?
      result = :passed
      comment += "\nOk"
    else
      result = :aborted
      comment += "\n#{exception}"
    end
    [result, comment]
  end

  # Parse server responce
  # @param
  # server_response [string] server response
  # @return
  # If the server response contains an error text, then return the short error text
  # Else return nil
  def parse_server_response(server_response)
    response = %r{<Error>.[1-8]</Error>}.match(server_response)
    response&.to_s
  end
end
