def run_rpc_specs
  [ {"arg1"=>1, "arg2"=>"2", "kwarg1"=>3.14, "kwarg2"=>false},
    {"arg1"=>true, "arg2"=>"2019-01-01", "kwarg1"=>[1,2], "kwarg2"=>{'a' => 1, 'b' => 'asdf'}}
  ].each do |args|
    it "can call static methods with no args or kwargs" do
      result = TestClass.clustered.echo_no_args_or_kwargs()
      expect(result.keys.sort).to eq [:request_id, :results, :success].sort
      expect(result[:success]).to eq true
      actual_result = result[:results].values.first['result'] rescue nil
      expect(actual_result).to eq({})
    end

    it "can call static methods with args" do
      result = TestClass.clustered.echo_args(args['arg1'], args['arg2'])
      expect(result.keys.sort).to eq [:request_id, :results, :success].sort
      expect(result[:success]).to eq true
      actual_result = result[:results].values.first['result'] rescue nil
      expect(actual_result).to eq args.slice("arg1", "arg2")
    end

    it "can call static methods with kwargs" do
      result = TestClass.clustered.echo_kwargs(kwarg1: args['kwarg1'], kwarg2: args['kwarg2'])
      expect(result.keys.sort).to eq [:request_id, :results, :success].sort
      expect(result[:success]).to eq true
      actual_result = result[:results].values.first['result'] rescue nil
      expect(actual_result).to eq args.slice("kwarg1", "kwarg2")
    end

    it "can call static methods with args and kwargs" do
      result = TestClass.clustered.echo_args_and_kwargs(args['arg1'], args['arg2'], kwarg1: args['kwarg1'], kwarg2: args['kwarg2'])
      ap result
      expect(result.keys.sort).to eq [:request_id, :results, :success].sort
      expect(result[:success]).to eq true
      actual_result = result[:results].values.first['result'] rescue nil
      expect(actual_result).to eq args
    end
  end
end