package com.github.aldurd392.ifthistinydo;

import android.graphics.drawable.ColorDrawable;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.os.Build;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.*;
import android.widget.*;

import android.os.AsyncTask;

import java.io.*;
import java.net.*;


import static android.view.View.VISIBLE;
import static android.view.View.GONE;




public class RuleActivity extends ActionBarActivity
                            implements RadioGroup.OnCheckedChangeListener {

    protected byte sensor = 0;
    protected byte expression = 0;
    protected byte argument = 0;

    protected final byte action = action_const.getActionConst(action_const.LED);  // In this first implementation action is fixed!

    public String uri;
    public String proxyAddress;
    public int threshold = 0;

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

        if (Build.VERSION.SDK_INT>=Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.setStatusBarColor(getResources().getColor(R.color.accent));
            getSupportActionBar().setBackgroundDrawable(new ColorDrawable(getResources().getColor(R.color.primary)));
        }
    }

    @Override
    public boolean onPrepareOptionsMenu (Menu menu) {
        return false;
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

        int rule = 0xFFFFFFFF;

        rule &= this.sensor;
        rule <<= 2;

        rule |= this.expression;
        rule <<= 16;

        System.out.println(this.threshold);

        rule |= this.threshold & 0xFFFF;
        rule <<= 3;

        rule |= this.action;
        rule <<= 3;

        rule |= this.argument;
        rule <<= 6;

        return rule;
    }

    public void onSendRuleClicked(View view) throws MalformedURLException {
        int rule;
        rule = makeRule();
        Log.d("ITTD", "Command: " + Integer.toBinaryString(rule));

        new HttpCommandSend().execute();
    }

    public class HttpCommandSend extends AsyncTask <Object, Object, Object>{

        private ProgressBar progressBar = (ProgressBar) findViewById(R.id.progressBar);
        private RelativeLayout relativeLayout = (RelativeLayout) findViewById(R.id.relativeLayout);

        private void disableEnableControls(boolean enable, ViewGroup vg){
            for (int i = 0; i < vg.getChildCount(); i++){
                View child = vg.getChildAt(i);
                if (child.getId() != R.id.progressBar) {
                    child.setEnabled(enable);
                }
                if (child instanceof ViewGroup){
                    disableEnableControls(enable, (ViewGroup)child);
                }
            }
        }

        @Override
        protected void onPreExecute(){
            disableEnableControls(false, relativeLayout);
            progressBar.setVisibility(VISIBLE);
        }

        @Override
        protected Object doInBackground(Object[] params){

            String[] splitProxy = proxyAddress.split(":");
            Proxy proxy;
            if (splitProxy.length == 1) {
                proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(splitProxy[0], 80));
            } else {
                proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(splitProxy[0], Integer.parseInt(splitProxy[1])));
            }

            URL url;
            try {
//                url = new URL("http://[fec0::4]:61616/rl");
                url = new URL(uri);
            } catch (MalformedURLException e) {
                e.printStackTrace();
                return null;
            }

            HttpURLConnection urlConnection = null;
            try {
                urlConnection = (HttpURLConnection) url.openConnection(proxy);
                urlConnection.setRequestMethod("PUT");
                urlConnection.setDoOutput(true);
//                urlConnection.setDoInput(false);

                //Send request
                DataOutputStream wr = new DataOutputStream (
                        urlConnection.getOutputStream ());
                wr.writeInt(268431808);
                wr.flush ();
                wr.close ();

                System.out.println(urlConnection.toString());
                System.out.println(urlConnection.getResponseCode());

                //Get Response
//                InputStream is = urlConnection.getInputStream();
//                BufferedReader rd = new BufferedReader(new InputStreamReader(is));
//                String line;
//                StringBuffer response = new StringBuffer();
//                while((line = rd.readLine()) != null) {
//                    response.append(line);
//                    response.append('\r');
//                }
//                rd.close();
//                return response.toString();
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (urlConnection != null) {
                    urlConnection.disconnect();
                }
            }

            return null;
        }

        @Override
        protected void onPostExecute(Object result) {
            disableEnableControls(true, relativeLayout);
            progressBar.setVisibility(GONE);
        }

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
                this.sensor = sensor_const.getSensorConst(sensor_const.SENSOR_TEMPERATURE);
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
        uri = getString(R.string.uriPlaceholderText);
        uriText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
               if (s.toString().equals("")){
                   t.uri = getString(R.string.uriPlaceholderText);
               } else{
                   t.uri = s.toString();  // Piggy thing!
               }
            }
        });

        EditText proxyText = (EditText) findViewById(R.id.proxyTextField);
        proxyAddress = getString(R.string.proxyPlaceholderText);
        proxyText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {}

            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().equals("")){
                    t.proxyAddress = getString(R.string.proxyPlaceholderText);
                }
                else {
                    t.proxyAddress = s.toString();  // Piggy thing!
                }
            }
        });


        /* Set default values: */
        this.sensor = sensor_const.getSensorConst(sensor_const.SENSOR_VOLTAGE);
        this.expression = expression_const.getExpressionConst(expression_const.EXPRESSION_EQUAL);
        this.threshold = 0;

        TextView thresholdTextView = (TextView) findViewById(R.id.selectedThresholdTextView);
        thresholdTextView.setText(String.format(getString(R.string.thresholdValueText), 0));  // Init with 0!

        SeekBar thresholdSeekBar = (SeekBar) findViewById(R.id.thresholdSeekBar);
        thresholdSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
           @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                TextView thresholdTextView = (TextView) findViewById(R.id.selectedThresholdTextView);
                thresholdTextView.setText(String.format(getString(R.string.thresholdValueText), progress));
           }

           @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

           }

           @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
                t.threshold = seekBar.getProgress();
           }
       });
    }
}
