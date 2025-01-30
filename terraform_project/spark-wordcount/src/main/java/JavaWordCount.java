import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function2;
import org.apache.spark.api.java.function.PairFunction;
import scala.Tuple2;

import java.util.Arrays;
import java.util.Iterator;

public class JavaWordCount {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: JavaWordCount <input_file> <output_dir>");
            System.exit(1);
        }

        String inputPath = args[0];
        String outputPath = args[1];

        // Set up Spark configuration and context
        SparkConf conf = new SparkConf().setAppName("Java WordCount");
        org.apache.spark.api.java.JavaSparkContext sc = new org.apache.spark.api.java.JavaSparkContext(conf);

        // Read the input file
        JavaRDD<String> input = sc.textFile(inputPath);

        // Perform the word count
        JavaPairRDD<String, Integer> counts = input
            .flatMap((FlatMapFunction<String, String>) line -> Arrays.asList(line.split(" ")).iterator())
            .mapToPair((PairFunction<String, String, Integer>) word -> new Tuple2<>(word, 1))
            .reduceByKey((Function2<Integer, Integer, Integer>) Integer::sum);

        // Save the results to the output directory
        counts.saveAsTextFile(outputPath);

        sc.close();
    }
}
