package com.github.aldurd392.ifthistinydo;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;


public class RuleActivity extends ActionBarActivity {

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

    protected byte sensor = 0;
    protected byte expression = 0;
    protected short threshold = 0;
    protected byte action = 0;
    protected byte argument = 0;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_rule);
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

}
