Dir['*rb'].each { |f| require_relative f }
require 'colored'

if __FILE__==$0
  DEBUG_S = true

  simulate_annealing(
    max_time: 20_000,
    init: lambda do
      MaximizingState.new(
        l2l3req_tl:                 7,
        l2l3req_o:                 13,
        l2l3resp_tl:               11,
        l2l3resp_o:                 4,
        l3memreq_tl:               66,
        l3memreq_o:                10,
        l3memresp_tl:              66,
        l3memresp_o:               49,
        mem_tl:                    66,
        mem_o:                     13,
      )
    end,
    shuffle: lambda { MaximizingState.new.shuffle }
  )

end
