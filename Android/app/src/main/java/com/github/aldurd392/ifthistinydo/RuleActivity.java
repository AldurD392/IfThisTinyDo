package com.github.aldurd392.ifthistinydo;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.*;


public class RuleActivity extends ActionBarActivity
                            implements RadioGroup.OnCheckedChangeListener {

    protected byte sensor = 0;
    protected byte expression = 0;
    protected byte argument = 0;

    protected final byte action = action_const.getActionConst(action_const.LED);  // In this first implementation action is fixed!

    public String uri;
    public short threshold = 0;

    public enum sensor_const {
        SENSOR_TEMPERATURE, SENSOR_HUMIDITY, SENSOR_LIGHT, SENSOR_VOLTAGE;

        public static byte getSensorConst(sensor_const s) {
            switch (s) {
                case SENSOR_TEMPERATURE:
                    return 0x00;
                case SENSOR_HUMIDITY:
                    return 0x01;
                case SENSOR_LIGHT:
                    return 0x02;
                default: // voltage sensor
                    return 0x03;
            }
        }
    }

    public enum expression_const {
        EXPRESSION_LOWER, EXPRESSION_EQUAL, EXPRESSION_GREATER;

        public static byte getExpressionConst(expression_const e) {
            switch (e) {
                case EXPRESSION_LOWER:
                    return 0x00;
                case EXPRESSION_EQUAL:
                    return 0x01;
                case EXPRESSION_GREATER:
                    return 0x02;
                default:
                    return 0x03;
            }
        }
    }

    public enum action_const {
        LED;

        public static byte getActionConst(action_const a) {
            switch (a) {
                case LED:
                    return 0x00;
                default: // check this default return
                    return 0x01;
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rule);
        this.setListeners();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_rule, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public int makeRule(){

        int rule = 0;

        rule |= this.sensor;
        rule <<= 2;

        rule |= this.expression;
        rule <<= 16;

        rule |= this.threshold;
        rule <<= 3;

        rule |= this.action;
        rule <<=3;

        rule |= this.argument;
        rule <<=6;

        return rule;
    }

    public void onSendRuleClicked(View view) {
        Log.d("ITTD", "Uri: " + this.uri);
        Log.d("ITTD", "Sensor: " + this.sensor);
        Log.d("ITTD", "Operator: " + this.expression);
        Log.d("ITTD", "Action: " + this.action);
        Log.d("ITTD", "Argument: " + this.argument);

        int rule;
        rule = makeRule();

        Log.d("ITTD", "Command: " + Integer.toBinaryString(rule));

    }

    public void ledToggleSelected(View view) {
        Switch toggleButton = (Switch) view;
        boolean isChecked = toggleButton.isChecked();

        if (toggleButton == findViewById(R.id.redLedSwitch)) {

            if (isChecked) { // add bit
                this.argument |= 0x01;
            } else { // remove bit
                this.argument &= 0x06;
            }

        } else if (toggleButton == findViewById(R.id.yellowLedSwitch)) {

            if (isChecked) { // add bit
                this.argument |= 0x02;
            } else { // remove bit
                this.argument &= 0x05;
            }

        } else {  // blueLedSwitch

            if (isChecked) { // add bit
                this.argument |= 0x04;
            } else { // remove bit
                this.argument &= 0x03;
            }
        }
    }

    @Override
    public void onCheckedChanged(RadioGroup group, int checkedId) {
        /* Called when a radio button in a group is checked. */
        switch(checkedId)
        {
            case R.id.lightRadioButton:
                this.sensor = sensor_const.getSensorConst(sensor_const.SENSOR_LIGHT);
                break;
            case R.id.humRadioButton:
                this.sensor = sensor_const.getSensorConst(sensor_const.SENSOR_HUMIDITY);
                break;
            case R.id.voltageRadioButton:
                this.sensor = sensor_const.getSensorConst(sensor_const.SENSOR_VOLTAGE);
                break;
            case R.id.tempRadioButton:
                this.sensor = sensor_const.getSensorConst(sensor_const.SENSOR_VOLTAGE);
                break;
            case R.id.lessThanRadioButton:
                this.expression = expression_const.getExpressionConst(expression_const.EXPRESSION_LOWER);
                break;
            case R.id.equalRadioButton:
                this.expression = expression_const.getExpressionConst(expression_const.EXPRESSION_EQUAL);
                break;
            case R.id.greaterThanRadioButton:
                this.expression = expression_const.getExpressionConst(expression_const.EXPRESSION_GREATER);
                break;
        }
    }

    public void setListeners() {
        RadioGroup sensorsRadioGroup = (RadioGroup) findViewById(R.id.sensorRadioGroup);
        sensorsRadioGroup.setOnCheckedChangeListener(this);

        RadioGroup operatorRadioGroup = (RadioGroup) findViewById(R.id.operatorRadioGroup);
        operatorRadioGroup.setOnCheckedChangeListener(this);

        final RuleActivity t = this;

        EditText uriText = (EditText) findViewById(R.id.uriTextField);
        uriText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                t.uri = s.toString();  // Piggy thing!
            }
        });

        EditText thresholdText = (EditText) findViewById(R.id.thresholdTextField);
       thresholdText.addTextChangedListener(new TextWatcher() {
           @Override
           public void beforeTextChanged(CharSequence s, int start, int count, int after) {
           }

           @Override
           public void onTextChanged(CharSequence s, int start, int before, int count) {
           }

           @Override
           public void afterTextChanged(Editable s) {
               t.threshold = Short.parseShort(s.toString());  // Piggy thing!
           }
       });
    }
}
