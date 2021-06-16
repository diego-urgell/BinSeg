//
// Created by Diego Urgell on 10/06/21.
//

#include <vector>

/**
 * Compute a single time the linear cumulative sum of the data and store it. This will allow to obtain
 * the sum of the whole data or just a segment in linear time.
 */
class CumsumLinear {

private:

    std::vector<double> linearCumsum;

public:

    Cumsum() = default;

    ~Cumsum() = default;

    virtual void init(const double *data, const int length) {
        double currTotal = 0;
        this -> linearCumsum.resize(length);
        for(int i = 1; i <= length; i++){
            currTotal += data[i];
            this -> linearCumsum[i] = currTotal;
        }
    }

    /**
     *
     * @param start inclusive
     * @param end inclusive
     * @return
     */
    double getLinearSum(int start, int end) {
        if (start > end || start < 0) throw "Index Error";
        if (start == 0) return linearCumsum[end];
        return linearCumsum[end] - linearCumsum[start - 1];
    }

    virtual double getCuadraticSum(int start, int end){
        throw "No quadratic sum in LinearCumsum";
    }

};


/**
 * Compute a single time the squared and linear cumulative sum of the data and store it. This will allow to obtain
 * the sum of the whole data or just a segment in linear time. In the algorithm class, a CumsumLinear pointer will be
 * stored so that polymorphism can be used to store CumsumSquared if necessary.
 */
class CumsumSquared: public CumsumLinear {

private:

    std::vector<double> quadraticCumsum;

public:

    void init(const double *data, const int length) {
        double currLinearTotal = 0;
        double currSquaredTotal = 0;
        this -> linearCumsum.resize(length);
        this -> quadraticCumsum.resize(length);
        for(int i = 1; i <= length; i++){
            currLinearTotal += data[i];
            currSquaredTotal += std::pow(data[i], 2);
            this -> linearCumsum[i] = currTotal;
            this -> quadraticCumsum[i] = currSquaredTotal;
        }
    }

    double getQuadraticSum(int start, int end){
        if (start > end || start < 0) throw "Index Error";
        if (start == 0) return quadraticCumsumCumsum[end];
        return quadraticCumsumCumsum[end] - quadraticCumsumCumsum[start - 1];
    }
};

class Segment {

};

// Virtual class
class Algorithm {
private:

public:
    Algorithm() = default;

    ~Algorithm() = default;

    virtual binseg() = 0;
};