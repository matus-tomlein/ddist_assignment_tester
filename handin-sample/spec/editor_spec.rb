require_relative 'spec_helper'

describe 'Editor' do
  describe '#process_event' do
    context 'writing' do
      let(:editor) { TestEditor.new }

      it 'adds text' do
        write editor, 0, 'Hey ho'
        expect(editor.content).to eq 'Hey ho'
      end

      it 'updates text' do
        write editor, 0, '123456789'
        write editor, 2, '222'
        expect(editor.content).to eq '122223456789'
        write editor, 0, '000'
        expect(editor.content).to eq '000122223456789'
      end

      it 'removes text' do
        write editor, 0, '123456789'
        delete editor, 2
        expect(editor.content).to eq '13456789'
        delete editor, 5
        expect(editor.content).to eq '1345789'
      end
    end

    context 'connecting more editors' do
      let(:editor1) { TestEditor.new }
      let(:editor2) { TestEditor.new }
      let(:editor3) { TestEditor.new }

      before :each do
        editor1.add_listener editor2
        editor1.add_listener editor3
        editor2.add_listener editor1
        editor3.add_listener editor1
      end

      context 'editing on server' do
        it 'propagates writing' do
          write editor1, 0, 'Hey ho'
          expect(editor2.content).to eq 'Hey ho'
          expect(editor3.content).to eq 'Hey ho'

          write editor1, 3, ' ho'
          expect(editor2.content).to eq 'Hey ho ho'
          expect(editor3.content).to eq 'Hey ho ho'
        end

        it 'propagates deleting' do
          write editor1, 0, '123456789'
          delete editor1, 2
          expect(editor1.content).to eq '13456789'
          expect(editor2.content).to eq '13456789'
          delete editor1, 5
          expect(editor1.content).to eq '1345789'
          expect(editor2.content).to eq '1345789'
        end
      end

      context 'editing on clients' do
        it 'propagates writing' do
          write editor2, 0, 'Hey ho'
          expect(editor3.content).to eq 'Hey ho'
          expect(editor1.content).to eq 'Hey ho'

          write editor3, 3, ' ho'
          expect(editor2.content).to eq 'Hey ho ho'
          expect(editor1.content).to eq 'Hey ho ho'
        end

        it 'propagates deleting' do
          write editor2, 0, '123456789'
          delete editor3, 2
          expect(editor1.content).to eq '13456789'
          expect(editor2.content).to eq '13456789'
          delete editor2, 5
          expect(editor3.content).to eq '1345789'
          expect(editor1.content).to eq '1345789'
        end
      end

      context 'simultaneous editing' do
        it 'synchronizes well' do
          write editor1, 0, ' ' * 1000
          t1 = Thread.new do
            write editor2, 0, '2' * 100
          end

          t2 = Thread.new do
            write editor3, 500, '3' * 100
          end

          t3 = Thread.new do
            write editor1, 1000, '1' * 100
          end

          t1.join
          t2.join
          t3.join

          expect(editor1.content).to include '1' * 100
          expect(editor1.content).to include '2' * 100
          expect(editor1.content).to include '3' * 100
          expect(editor2.content).to eq editor1.content
          expect(editor3.content).to eq editor1.content
        end
      end
    end
  end
end

def write(editor, position, text)
  editor.process_event Event.set_caret_position(editor.key, position)

  text.each_char do |char|
    event = Event.relative_write editor.key,
      RelativePosition.generate_key, nil, char
    editor.process_event event
    editor.process_event Event.move_caret_right editor.key
  end
end

def delete(editor, position)
  editor.process_event Event.set_caret_position(editor.key, position)
  event = Event.relative_delete editor.key, nil
  editor.process_event event
end
