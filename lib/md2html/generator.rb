require_relative "generator/body_visitor"

module Md2Html
  module Generator
    def self.generate(ast)
      body_visitor.visit(ast)
    end

    private

    def self.body_visitor
      BodyVisitor.new
    end
  end
end
