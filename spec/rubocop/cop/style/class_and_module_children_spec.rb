# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::ClassAndModuleChildren, :config do
  subject(:cop) { described_class.new(config) }

  context 'nested style' do
    let(:cop_config) { { 'EnforcedStyle' => 'nested' } }

    it 'registers an offense for not nested classes' do
      inspect_source(cop, ['class FooClass::BarClass',
                           'end'])

      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use nested module/class definitions instead of compact style.'
      ]
      expect(cop.highlights).to eq ['FooClass::BarClass']
    end

    it 'registers an offense for not nested modules' do
      inspect_source(cop, ['module FooModule::BarModule',
                           'end'])

      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use nested module/class definitions instead of compact style.'
      ]
      expect(cop.highlights).to eq ['FooModule::BarModule']
    end

    it 'accepts nested children' do
      inspect_source(cop,
                     ['class FooClass',
                      '  class BarClass',
                      '  end',
                      'end',
                      '',
                      'module FooModule',
                      '  module BarModule',
                      '  end',
                      'end'
                     ])
      expect(cop.offenses).to be_empty
    end

    it 'accepts :: in parent class on inheritance' do
      inspect_source(cop,
                     ['class FooClass',
                      '  class BarClass',
                      '  end',
                      'end',
                      '',
                      'class BazClass < FooClass::BarClass',
                      'end'
                     ])
      expect(cop.offenses).to be_empty
    end
  end

  context 'compact style' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    shared_examples :source_with_offense_for_classes_with_nested_children do
      it 'registers a offense for classes with nested children' do
        inspect_source(cop,
                       ['class FooClass',
                        '  class BarClass',
                        '  end',
                        'end'
                       ])
        expect(cop.offenses.size).to eq 1
        expect(cop.messages).to eq [
          'Use compact module/class definition instead of nested style.'
        ]
        expect(cop.highlights).to eq ['FooClass']
      end
    end

    shared_examples :source_without_offense_for_classes_with_nested_children do
      it 'accepts classes with nested children' do
        inspect_source(cop,
                       ['class FooClass',
                        '  class BarClass',
                        '  end',
                        'end'
                       ])
        expect(cop.offenses).to be_empty
      end
    end

    shared_examples :source_with_offense_for_modules_with_nested_children do
      it 'registers a offense for modules with nested children' do
        inspect_source(cop,
                       ['module FooModule',
                        '  module BarModule',
                        '  end',
                        'end'
                       ])
        expect(cop.offenses.size).to eq 1
        expect(cop.messages).to eq [
          'Use compact module/class definition instead of nested style.'
        ]
        expect(cop.highlights).to eq ['FooModule']
      end
    end

    shared_examples :source_without_offense_for_modules_with_nested_children do
      it 'accepts modules with nested children' do
        inspect_source(cop,
                       ['module FooModule',
                        '  module BarModule',
                        '  end',
                        'end'
                       ])
        expect(cop.offenses).to be_empty
      end
    end

    shared_examples :source_without_offense_for_compact_classes_modules do
      it 'accepts compact style for classes / modules' do
        inspect_source(cop,
                       ['class FooClass::BarClass',
                        'end',
                        '',
                        'module FooClass::BarModule',
                        'end'
                       ])
        expect(cop.offenses).to be_empty
      end
    end

    shared_examples :source_without_offense_for_more_than_one_child do
      it 'accepts nesting for classes / modules with more than one child' do
        inspect_source(cop,
                       ['class FooClass',
                        '  class BarClass',
                        '  end',
                        '  class BazClass',
                        '  end',
                        'end',
                        '',
                        'module FooModule',
                        '  module BarModule',
                        '  end',
                        '  class BazModule',
                        '  end',
                        'end'
                       ])
        expect(cop.offenses).to be_empty
      end
    end

    shared_examples :source_without_offense_for_classes_with_single_method do
      it 'accepts class / module with single method' do
        inspect_source(cop,
                       ['class FooClass',
                        '  def bar_method',
                        '  end',
                        'end'
                       ])
        expect(cop.offenses).to be_empty
      end
    end

    context 'without enforced_on provided' do
      it_behaves_like :source_with_offense_for_classes_with_nested_children

      it_behaves_like :source_with_offense_for_modules_with_nested_children

      it_behaves_like :source_without_offense_for_compact_classes_modules

      it_behaves_like :source_without_offense_for_more_than_one_child

      it_behaves_like :source_without_offense_for_classes_with_single_method
    end

    context 'when only enforcing on classes' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'compact',
          'EnforcedOn' => 'class' }
      end

      it_behaves_like :source_with_offense_for_classes_with_nested_children

      it_behaves_like :source_without_offense_for_modules_with_nested_children

      it_behaves_like :source_without_offense_for_compact_classes_modules

      it_behaves_like :source_without_offense_for_more_than_one_child

      it_behaves_like :source_without_offense_for_classes_with_single_method
    end

    context 'when only enforcing on modules' do
      let(:cop_config) do
        { 'EnforcedStyle' => 'compact',
          'EnforcedOn' => 'module' }
      end

      it_behaves_like :source_without_offense_for_classes_with_nested_children

      it_behaves_like :source_with_offense_for_modules_with_nested_children

      it_behaves_like :source_without_offense_for_compact_classes_modules

      it_behaves_like :source_without_offense_for_more_than_one_child

      it_behaves_like :source_without_offense_for_classes_with_single_method
    end
  end
end
