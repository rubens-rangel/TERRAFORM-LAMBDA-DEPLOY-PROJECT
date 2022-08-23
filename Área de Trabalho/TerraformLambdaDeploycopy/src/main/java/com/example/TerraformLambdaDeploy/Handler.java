package com.example.TerraformLambdaDeploy;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;


import java.util.Map;
import java.util.Date;
import java.sql.Timestamp;

public class Handler implements RequestHandler<Map<String,String>, String>{
    Gson gson = new GsonBuilder().setPrettyPrinting().create();
    @Override
    public String handleRequest(Map<String,String> event, Context context)
    {
        LambdaLogger logger = context.getLogger();
        Date date = new Date();
        Timestamp timestamp = new Timestamp(date.getTime());
        String myenv = System.getenv("MY_ENV");

        String response = new String(myenv + "_" + timestamp);

        return response;
    }
}