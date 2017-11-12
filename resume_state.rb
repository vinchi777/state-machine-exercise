require 'state_machine'
require './resume_prompt'

class ResumeState
  attr_accessor :first_name, :last_name, :job_position, :company
  include ResumePrompt

  state_machine :state, initial: :main_menu do
    before_transition on: any, :do => :clear

    after_transition on: :enter_name, do: :ask_full_name
    after_transition on: :enter_experience, do: :ask_work_experience
    after_transition on: :quit, do: :display_result
    after_transition on: :start, do: :display_main_menu

    event :enter_name do
      transition :main_menu => :full_name
    end

    event :enter_experience do
      transition :main_menu => :work_experience
    end

    event :quit do
      transition :main_menu => :complete
    end

    event :start do
      transition all => :main_menu
    end
  end

  state_machine :work_state, initial: :work_menu, namespace: 'current'    do
    before_transition on: any, :do => :clear

    after_transition on: :enter_job_position, do: :ask_current_job_position
    after_transition on: :enter_company, do: :ask_current_company
    after_transition on: :start_work_experience, do: :display_work_exp_menu

    event :enter_job_position do
      transition :work_menu => :job_position
    end

    event :enter_company do
      transition :work_menu => :company
    end

    event :start_work_experience do
      transition all => :work_menu
    end
  end

  def initialize
    @first_name = nil
    @last_name = nil
    @company = nil
    @job_position = nil
    super()
  end 
end
