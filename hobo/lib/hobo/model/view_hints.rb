module Hobo
  module Model
    class ViewHints

      class << self

        # allows delayed set of children in order to avoid circular references
        # triggered by declaring children in the model
        def children(*args)
          if args.empty? # reader
            if @children_args.nil? # value already set
              @children ||= []
            else # set
              child_model = model.reflect_on_association(@children_args.first).klass
              if child_model.view_hints.parent.nil? and !child_model.view_hints.parent_defined
                parent = model.reverse_reflection(@children_args.first)
                child_model.view_hints.parent(parent.name, :undefined => true) if parent
              end
              @children_args = nil
              @children = args
            end
          else # writer (only stores the args for delayed setting)
            @children_args = args
          end
        end

        def inline_booleans(*args)
          if args.empty? # reader
            @inline_booleans ||= []
          else # writer
            @inline_booleans = if args[0] == true
                                 model.columns.select { |c| c.type == :boolean }.*.name
                               else
                                 args.*.to_s
                               end
          end
        end

        def parent(*args)
          if args.empty? #reader
            @parent
          else # writer
            options = args.extract_options!
            parent_defined(true) unless options[:undefined]
            @parent = args.first
          end
        end

        def parent_defined(arg=nil)
          if arg.nil?
            @parent_defined
          else
            @parent_defined = arg
          end
        end

        def paginate?(arg=nil)
          if arg.nil?
            @paginate ||= !sortable?
          else
            @paginate = arg
          end
        end

        def sortable?(arg=nil)
          if arg.nil?
            @sortable ||= defined?(ActiveRecord::Acts::List::InstanceMethods) &&
                          model < ActiveRecord::Acts::List::InstanceMethods &&
                          model.new.try.scope_condition == "1 = 1"
          else
            @sortable = arg
          end
        end

        def _name
          @_name ||= name.sub(/Hints$/, '')
        end

        def model
          @model ||= _name.constantize
        end

        def primary_children
          children.first
        end

        def secondary_children
          children.rest
        end


  ##### LEGACY METHODS TO REMOVE #####

        def model_name(*)
          raise NotImplementedError, "ViewHints.model_name is no longer supported, please use model.model_name.human and set a the activerecord.models.<model_name> key in a locale file"
        end

        def model_name_plural(*)
          raise NotImplementedError, "ViewHints.model_name_plural is no longer supported, please use model.model_name.human(:count => n) and set a the activerecord.models.<model_name> key in a locale file"
        end

        def field_name(*)
          raise NotImplementedError, "ViewHints.field_name is no longer supported, please use model..human_attribute_name and set a the activerecord.attributes.<model_name>.<field_name> key in a locale file"
        end

        def field_names(*)
          raise NotImplementedError, "ViewHints.field_names is no longer supported, please set the activerecord.attributes.<model_name>.<field_name> keys in a locale file"
        end

      end

    end

  end
end
