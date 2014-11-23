Dir['*rb'].each { |f| require_relative f }
require 'colored'

if __FILE__==$0
  DEBUG_S = true

  simulate_annealing(
    max_time: 20_000,
    init: lambda do
      BalancedHitState.new(
        l2l3req_tl:                11,
        l2l3resp_tl:               11,
        l3memreq_tl:               66,
        l3memresp_tl:              66,
        mem_tl:                    66,
        l2l3req_o:                  0,
        l3memreq_o:                10,
        mem_o:                   10+1,
        l3memresp_o:          10+1+36,
        l2l3resp_o: (10+11+36+9+9)%11,
      )
    end,
    shuffle: lambda { BalancedHitState.new.shuffle }
  )

end

