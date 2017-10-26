# a mixin to add ability for organization to express themselves as flat trees
module Flattenable
  extend ActiveSupport::Concern

  class_methods do
    # this turns the
    def flat_tree
      child_mapper = lambda do |tree, node|
        tree << node
        unless node.children.empty?
          tree += node.children.reduce([], &child_mapper)
        end
        return tree.flatten
      end
      includes(children: { children: [:children] })
        .where(organization_type: organization_types[:root]).inject([], &child_mapper)
    end
  end

  included do
    def flat_tree_description
      prefix = ''
      org_parent = parent
      while org_parent
        prefix << '--'
        org_parent = org_parent.parent
      end
      "#{prefix} #{description}"
    end
  end
end