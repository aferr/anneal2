Dir['*rb'].each { |f| require_relative f }
require 'colored'

if __FILE__==$0
  DEBUG_S = true

  simulate_annealing(
    max_time: 20_000,
    init: lambda do
      MaximizingState.new(
        l2l3req_tl:                66,
        l2l3req_o:                  0,
        l2l3resp_tl:               66,
        l2l3resp_o:                65,
        l3memreq_tl:               66,
        l3memreq_o:                10,
        l3memresp_tl:              66,
        l3memresp_o:               47,
        mem_tl:                    66,
        mem_o:                     11,
      )
    end,
    shuffle: lambda { MaximizingState.new.shuffle }
  )

end
