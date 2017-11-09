require 'ast'
module OrigenVerilog
  # The base processor, this provides a default handler for
  # all node types and will not make any changes to the AST,
  # i.e. an equivalent AST will be returned by the process method.
  #
  # Child classes of this should be used to implement additional
  # processors to modify or otherwise work with the AST.
  #
  # @see http://www.rubydoc.info/gems/ast/2.0.0/AST/Processor
  class Processor
    include ::AST::Processor::Mixin

    def run(node)
      process(node)
    end

    # Override the default implementation of this, to allow arrays
    # to be returned and when a handler returns nil the node is removed
    def process(node)
      return if node.nil?
      return node unless node.respond_to?(:to_ast)

      node = node.to_ast

      # Invoke a specific handler
      on_handler = :"on_#{node.type}"
      if respond_to? on_handler
        new_node = send on_handler, node
      else
        new_node = handler_missing(node)
      end

      new_node if new_node
    end

    # Some of our processors remove a wrapping node from the AST, returning
    # a node of type :inline containing the children which should be inlined.
    # Here we override the default version of this method to deal with handlers
    # that return an inline node in place of a regular node.
    def process_all(nodes)
      results = []
      nodes.to_a.each do |node|
        n = process(node)
        if n
          if n.is_a?(Inline)
            results += n
          else
            results << n
          end
        end
      end
      results
    end

    def handler_missing(node)
      node.updated(nil, process_all(node.children))
    end

    def inline(nodes)
      Inline.new(nodes)
    end

    class Inline < ::Array
    end
  end
end
