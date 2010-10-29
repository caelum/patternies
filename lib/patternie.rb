require 'rubygems'
require 'active_support'
require 'rails'

class Accumulator
  def initialize(acc)
    @acc = acc
  end
  def method_missing(sym, *args)
    @acc << sym
  end
end

module Estudante
  def self.acc
    @@acc ||= []
  end
  
  def self.case_fields(&block)
    Accumulator.new(acc).instance_eval &block
  end

  case_fields {turma}
end

class AlunoUniversitario
  include Estudante
  
  attr_reader :turma
  def initialize(turma)
    @turma = turma
  end
  
end
class ProcMatcher
  
  def matches?(p, obj)
    @obj = obj
    self.instance_eval &p
  end
  
  def method_missing(method, *args)
    if @obj.kind_of?(method.to_s.constantize)
      field = method.to_s.constantize.acc[0]
      required_value = args[0] # 55
      @obj.send(field)==required_value
    else
      false
    end
  end
  
end
class PatternMatcher
  def initialize(pattern)
    @pattern = pattern
  end
  def matches?(*args)
    is_same_type = (@pattern.kind_of?(Class) && args[0].kind_of?(@pattern))
    is_equal = @pattern==args[0]
    is_proc_matches = (@pattern.kind_of?(Proc) && ProcMatcher.new.matches?(@pattern,args[0]))
    is_same_type || is_equal || is_proc_matches
  end
end

class Fa
  
  @@acc = []
  def self.f(*args, &block)
    if block_given?
      @@acc << [PatternMatcher.new(args[0]), block]
    else
      found = @@acc.find { |el| el[0].matches?(*args) }
      found[1].call(*args) if found
    end
  end
  
  f(1) { 15 }
  f(Integer) {13}
  f(proc {Estudante(30)}) { "uhu! achei universitario!" }
  f(proc {Estudante(35, turma)}) {"Pq 35 eh o que ha!" }
  
  puts f(1)
  puts f(22222)
  puts f(AlunoUniversitario.new(30))
  puts f(AlunoUniversitario.new(35))
end
