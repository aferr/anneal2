Dir['*rb'].each { |f| require_relative f }
require 'colored'

if __FILE__==$0
  DEBUG_S = true

  simulate_annealing(
    max_time: 20_000,
    init: lambda do
      BalancedHitState.new(
        l2l3req_tl:                4,
        l2l3resp_tl:               11,
        l3memreq_tl:               66,
        l3memresp_tl:              66,
        mem_tl:                    66,
        l2l3req_o:                  2,
        l3memreq_o:                 6,
        mem_o:                      7,
        l3memresp_o:               39,
        l2l3resp_o:                18,
      )
    end,
    shuffle: lambda { BalancedHitState.new.shuffle },
  )

end

