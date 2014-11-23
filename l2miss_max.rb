Dir['*rb'].each { |f| require_relative f }
require 'colored'

if __FILE__==$0
  DEBUG_S = true

  simulate_annealing(
    max_time: 20_000,
    init: lambda do
      MaximizingBalanced.new( 
        l2l3req_tl: 1,
        l2l3req_o: 16,
        l2l3resp_tl: 9,
        l2l3resp_o: 10,
        l3memreq_tl: 26,
        l3memreq_o: 8,
        l3memresp_tl: 9,
        l3memresp_o: 61,
        mem_tl: 78,
        mem_o: 67
      )
    end,
    shuffle: lambda { MaximizingBalanced.new.shuffle }
  )

end

