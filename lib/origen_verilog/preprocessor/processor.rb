module OrigenVerilog
  module Preprocessor
    class Processor < OrigenVerilog::Processor
      def run(ast, env)
        @env = env
        ast = process(ast)
        Concatenator.new.run(ast)
      end

      def on_include(node)
        path = node.to_a[0]
        file = path if File.exist?(path)
        unless file
          dir = ([Dir.pwd] + Array(env[:source_dirs])).find do |dir|
            f = File.join(dir, path)
            File.exist?(f)
          end
          file = File.join(dir, path) if dir
        end
        unless file
          puts "The file #{path} could not be found!"
          puts "#{node.file}:#{node.line_number}"
          exit 1
        end
        nodes = process(Parser.parse_file(file)).children
        node.updated(:file, [file] + nodes)
      end

      def on_define(node)
        n = node.find(:name)
        name = n.to_a[0]
        if a = n.find(:arguments)
          args = a.to_a
        end
        if n = node.find(:text)
          text = n.to_a.first
        end
        env[name] = Define.new(name: name, args: args, text: text)
        nil
      end

      def on_undef(node)
        env[node.to_a[0]] = nil
      end

      def on_ifdef(node)
        elsif_nodes = node.find_all(:elsif)
        else_node = node.find(:else)
        enable, *nodes = *node

        # The number of lines needs to be tracked here and blank lines (nil) are injected in place
        # of un-enabled ifdef branches so that the source file line numbers will be reported correctly
        # later in the Verilog parse stage
        prelines = 0
        postlines = 0

        if node.type == :ifdef ? env[enable] : !env[enable]
          content = process_all(nodes)
        else
          prelines += node.number_of_lines + 1
        end

        elsif_nodes.each do |elsif_node|
          enable, *nodes = *elsif_node
          if !content && env[enable]
            content = process_all(nodes)
          else
            if content
              postlines += elsif_node.number_of_lines + 1
            else
              prelines += elsif_node.number_of_lines + 1
            end
          end
        end

        if else_node
          if content
            postlines += else_node.number_of_lines + 1
          else
            content = process_all(else_node.children)
          end
        end

        prelines = node.updated(:text_block, ["\n" * prelines])
        postlines = node.updated(:text_block, ["\n" * postlines])

        inline([prelines] + (content || []) + [postlines])
      end
      alias_method :on_ifndef, :on_ifdef

      def on_macro_reference(node)
        if define = env[node.to_a[0]]
          if a = node.find(:arguments)
            args = a.to_a
          end
          node.updated(:text_block, [define.value(node, args)])

        else
          puts "A reference has been made to macro #{node.to_a[0]} but it hasn't been defined yet!"
          puts "#{node.file}:#{node.line_number}"
          exit 1
        end
      end

      def on_else(node)
        # Do nothing, will be processed by the ifdef handler if required
      end
      alias_method :on_elsif, :on_else

      private

      class Define
        attr_reader :name, :args, :text

        def initialize(options)
          @name = options[:name]
          @args = options[:args] || []
          @text = options[:text]
        end

        def value(node, arguments)
          return '' unless text
          arguments = Array(arguments)
          unless args.size == arguments.size
            puts "Macro #{node.to_a[0]} required #{args.size} arguments, but only #{arguments.size} have been given!"
            puts "#{node.file}:#{node.line_number}"
            exit 1
          end
          t = text
          args.each_with_index do |a, i|
            t = t.gsub(a, arguments[i])
          end
          t
        end
      end

      def env
        @env
      end
    end
  end
end
