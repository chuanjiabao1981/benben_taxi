class AddSmsGateRetMsgToRegisterVerification < ActiveRecord::Migration
  def change
    add_column :register_verifications, :sms_gate_ret_raw_msg,:string 
  end
end
