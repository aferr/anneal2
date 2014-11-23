Dir['*rb'].each { |f| require_relative f }

class State

  def initialize o={}

    @o = {
      max: {
        :l2l3req_tl   => 25,
        :l2l3req_o    => ( o[:l2l3req_tl] || 15) *2, 
        :l2l3resp_tl  => 25,
        :l2l3resp_o   => ( o[:l2l3resp_tl] || 15) *2,
        :l3memreq_tl  => o[:mem_tl] || 120,
        :l3memreq_o   => ( o[:l3memreq_tl] || 15) *2,
        :l3memresp_tl => o[:mem_tl] || 120,
        :l3memresp_o  => ( o[:l3memresp_tl] || 120) *2,
        :mem_tl       => 120,
        :mem_o        => ( o[:mem_tl] || 120) *2
      },
      min: {
        :l2l3req_tl   => 1,
        :l2l3req_o    => 0,
        :l2l3resp_tl  => 1,
        :l2l3resp_o   => 0,
        :l3memreq_tl  => 1,
        :l3memreq_o   => 0,
        :l3memresp_tl => 1,
        :l3memresp_o  => 0,
        :mem_tl       => 66,
        :mem_o        => 0
      },
      deltas: lambda{ |p| -3.upto(3).to_a - [0] },
    }.merge o

    @max = @o[:max]
    @min = @o[:min]
    @deltas = @o[:deltas]

    @params = @o[:params] || [
      :l2l3req_tl,
      :l2l3req_o, 
      :l2l3resp_tl, 
      :l2l3resp_o,  
      :l3memreq_tl, 
      :l3memreq_o,  
      :l3memresp_tl,
      :l3memresp_o, 
      :mem_tl,     
      :mem_o,       
    ]

    # @params.each do |p|
    #   eval "instance_variable_set(\"#{p}\",o[:#{p}]) unless o[:#{p}].nil?"
    # end

  end

  def legal o
    @params.each do |p|
      return false if o[p] > @max[p]
      return false if o[p] < @min[p]
    end
    # return true if @params.reject{|p| p.to_s.include? "_o"}.nil?
    # return false if @params.reject{|p| p.to_s.include? "_o" }.
    #   map{ |p| o[p] }.reduce(:lcm) > 20_000
    return true
  end

  def badprime n
    return false if n < 20
    not [*2..n-1].inject(false){ |notprime,i| notprime |= (n%i == 0) }
  end

  # Generates a neighbor of this state by randomly selecting a parameter and 
  # then changing it by a randomly selected delta
  def neighbor &block
    factory = block || lambda { |o| State.new o }
    new_params = @o.merge(
      (p = @params.sample) => @o[p] + @deltas.call(p).sample
    )
    legal(new_params)?
      factory.call(new_params) :
      neighbor
  end

  # Lower energy -> more likely to accept.
  # Suitable options: 
  # EV(l3 hit latency)
  # EV(l3 miss latency)
  # l3 mss latency constrained to best l3 hit latency
  # weighted balance of l3 hit/miss latency
  def energy
      (lat = l3_miss_latencies @o).inject{ |a,l| a+=l }/lat.size.to_f
  end

  #Randomly generate a new legal 
  def shuffle &block
    factory = block || lambda { |o| puts o; State.new o }
    p = @params.inject({}) do |params,p|
      params[p] = @min[p].upto(@max[p]).to_a.sample
      params
    end 
    legal(p) ? factory.call(@o.merge(p)) : shuffle(&block)
  end

  def to_s
    @params.inject({}){ |h,p| h[p] = @o[p]; h }.to_s
  end

end

class MaximizingState < State

  def initialize o={}
    super ({
      params: [
        :l2l3req_o, 
        :l2l3resp_o,  
        :l3memreq_o,  
        :l3memresp_o, 
        :mem_o,
      ]
    }.merge o)
  end

  def energy
      super * -1
  end

  def shuffle
    super{ |o| MaximizingState.new o }
  end

  def neighbor
    super{ |o| MaximizingState.new o}
  end
end

class BalancedHitState < State

  def energy
    miss = super
    hit = (lat = l3_hit_latencies @o).inject{ |a,l| a+=l }/lat.size.to_f
    0.9 * hit + 0.1 * miss
  end

  def shuffle
    super{ |o| BalancedHitState.new o }
  end

  def neighbor
    super{ |o| BalancedHitState.new o}
  end
end

class MaximizingBalanced < State

  def initialize o={}
    super ({
      params: [
        :l2l3req_o, 
        :l2l3resp_o,  
        :l3memreq_o,  
        :l3memresp_o, 
        :mem_o,
      ]
    }.merge o)
  end

  def energy
    miss = super
    hit = (lat = l3_hit_latencies @o).inject{ |a,l| a+=l }/lat.size.to_f
    -1 * (0.9 * hit + 0.1 * miss)
  end

  def shuffle
    super{ |o| MaximizingBalanced.new o }
  end

  def neighbor
    super{ |o| MaximizingBalanced.new o}
  end
end

class HitState < State
  def initialize o={}
    params = o[:params] || [
      :l2l3req_tl,
      :l2l3req_o, 
      :l2l3resp_tl, 
      :l2l3resp_o,  
    ]

    super o.merge( params: params )
  end
end

