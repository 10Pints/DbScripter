using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Shapes;

namespace SI.Software.SharedControls.Controls
{
    /// <summary>
    /// Interaction logic for AdvancedSlider.xaml
    /// </summary>
    public partial class AdvancedSlider : UserControl, IDisposable
    {
        #region Fields

        /// <summary>
        /// Get or set the selected thumb.
        /// </summary>
        private Thumb selectedThumb;

        /// <summary>
        /// Get the dictionary that tracks a thumbs track.
        /// </summary>
        private readonly Dictionary<Thumb, Track> thumbTrackDictionary = new Dictionary<Thumb, Track>();

        /// <summary>
        /// Get the dictionary that references the index in the Values array that a thumb is bound to.
        /// </summary>
        private readonly Dictionary<Track, int> trackValueIndexDictionary = new Dictionary<Track, int>();
        
        /// <summary>
        /// Get or set the thumb stopped moving timer.
        /// </summary>
        private readonly Timer thumbStoppedMovingTimer;

        /// <summary>
        /// Get or set the amount of milliseconds the thumb is idle for before triggering an update.
        /// </summary>
        private readonly int idleMillisecondsBeforeUpdateTriggerWhileDraggingThumb = 100;

        #endregion

        #region Properties

        /// <summary>
        /// Get or set the value. This is a dependency property.
        /// </summary>
        public double Value1
        {
            get { return (double)GetValue(Value1Property); }
            set { SetValue(Value1Property, value); }
        }

        /// <summary>
        /// Get or set the value. This is a dependency property.
        /// </summary>
        public double Value2
        {
            get { return (double)GetValue(Value2Property); }
            set { SetValue(Value2Property, value); }
        }

        /// <summary>
        /// Get or set the minimum value. This is a dependency property.
        /// </summary>
        public double Minimum
        {
            get { return (double)GetValue(MinimumProperty); }
            set { SetValue(MinimumProperty, value); }
        }

        /// <summary>
        /// Get or set the maximum value. This is a dependency property.
        /// </summary>
        public double Maximum
        {
            get { return (double)GetValue(MaximumProperty); }
            set { SetValue(MaximumProperty, value); }
        }

        /// <summary>
        /// Get or set the tick frequency. This is a dependency property.
        /// </summary>
        public double TickFrequency
        {
            get { return (double)GetValue(TickFrequencyProperty); }
            set { SetValue(TickFrequencyProperty, value); }
        }

        /// <summary>
        /// Get or set the tick placement. This is a dependency property.
        /// </summary>
        public TickPlacement TickPlacement
        {
            get { return (TickPlacement)GetValue(TickPlacementProperty); }
            set { SetValue(TickPlacementProperty, value); }
        }

        /// <summary>
        /// Gets or sets a value that indicates whether the Slider automatically moves the Thumb to the closest tick mark. This is a dependency property.
        /// </summary>
        public bool IsSnapToTickEnabled
        {
            get { return (bool)GetValue(IsSnapToTickEnabledProperty); }
            set { SetValue(IsSnapToTickEnabledProperty, value); }
        }

        /// <summary>
        /// Get or set if ticks are started from zero. If this is false ticks will start from the minimum value, if this is true they will start from zero.. This is a dependency property.
        /// </summary>
        public bool SnapTicksToStartFromZero
        {
            get { return (bool)GetValue(SnapTicksToStartFromZeroProperty); }
            set { SetValue(SnapTicksToStartFromZeroProperty, value); }
        }

        /// <summary>
        /// Get if a drag is in progress. This is a dependency property.
        /// </summary>
        public bool IsDragInProgress
        {
            get { return (bool)GetValue(IsDragInProgressProperty); }
            protected set { SetValue(IsDragInProgressProperty, value); }
        }

        /// <summary>
        /// Get or set if all thumbs other than the current one are dimmed during drag. This is a dependency property.
        /// </summary>
        public bool DimAllOtherThumbsDuringDrag
        {
            get { return (bool)GetValue(DimAllOtherThumbsDuringDragProperty); }
            set { SetValue(DimAllOtherThumbsDuringDragProperty, value); }
        }

        /// <summary>
        /// Get or set the opacity of dimmed thumbs. This is a dependency property.
        /// </summary>
        public double DimOpacity
        {
            get { return (double)GetValue(DimOpacityProperty); }
            set { SetValue(DimOpacityProperty, value); }
        }

        /// <summary>
        /// Get or set the visibility of the range highlight. This is a dependency property.
        /// </summary>
        public Visibility RangeVisibility
        {
            get { return (Visibility)GetValue(RangeVisibilityProperty); }
            set { SetValue(RangeVisibilityProperty, value); }
        }

        /// <summary>
        /// Get or set if the range is re-evaluated when a value in the Values collection changes. This is a dependency property.
        /// </summary>
        public bool ReEvaluateRangeOnValueChanged
        {
            get { return (bool)GetValue(ReEvaluateRangeOnValueChangedProperty); }
            set { SetValue(ReEvaluateRangeOnValueChangedProperty, value); }
        }

        /// <summary>
        /// Get the minimum value in the Values collection. This is a dependency property.
        /// </summary>
        public double MinimumValue
        {
            get
            {
                if (!ReEvaluateRangeOnValueChanged)
                    ReEvaluateValuesForMinimumAndMaximum();

                return (double)GetValue(MinimumValueProperty);
            }
            protected set { SetValue(MinimumValueProperty, value); }
        }

        /// <summary>
        /// Get the maximum value in the Values collection. This is a dependency property.
        /// </summary>
        public double MaximumValue
        {
            get
            {
                if (!ReEvaluateRangeOnValueChanged)
                    ReEvaluateValuesForMinimumAndMaximum();

                return (double)GetValue(MaximumValueProperty);
            }
            protected set { SetValue(MaximumValueProperty, value); }
        }

        /// <summary>
        /// Get or set converter used for value label conversion. This is a dependency property.
        /// </summary>
        public IValueConverter ValueLabelConverter
        {
            get { return (IValueConverter)GetValue(ValueLabelConverterProperty); }
            set { SetValue(ValueLabelConverterProperty, value); }
        }

        /// <summary>
        /// Get or set converter parameter used for value label conversion. This is a dependency property.
        /// </summary>
        public object ValueLabelConverterParameter
        {
            get { return GetValue(ValueLabelConverterParameterProperty); }
            set { SetValue(ValueLabelConverterParameterProperty, value); }
        }

        /// <summary>
        /// Get or set if the values are always shown. This is a dependency property.
        /// </summary>
        public bool AlwaysShowValues
        {
            get { return (bool)GetValue(AlwaysShowValuesProperty); }
            set { SetValue(AlwaysShowValuesProperty, value); }
        }

        /// <summary>
        /// Get or set if the values are always hidden. This is a dependency property.
        /// </summary>
        public bool AlwaysHideValues
        {
            get { return (bool)GetValue(AlwaysHideValuesProperty); }
            set { SetValue(AlwaysHideValuesProperty, value); }
        }

        /// <summary>
        /// Get or set the mode. This is a dependency property.
        /// </summary>
        public AdvancedSliderMode Mode
        {
            get { return (AdvancedSliderMode)GetValue(ModeProperty); }
            set { SetValue(ModeProperty, value); }
        }

        /// <summary>
        /// Get or set if any visible value labels are placed at the top when they are shown. When this is false the value labels for some modes may appear below the slider, depending on styling. This is a dependency property.
        /// </summary>
        public bool AllValueLabelsAtTopWhenVisible
        {
            get { return (bool)GetValue(AllValueLabelsAtTopWhenVisibleProperty); }
            set { SetValue(AllValueLabelsAtTopWhenVisibleProperty, value); }
        }

        /// <summary>
        /// Get or set the ticks. This is a dependency property.
        /// </summary>
        public DoubleCollection Ticks
        {
            get { return (DoubleCollection)GetValue(TicksProperty); }
            set { SetValue(TicksProperty, value); }
        }

        /// <summary>
        /// Occurs when value 1 changes.
        /// </summary>
        public event RoutedPropertyChangedEventHandler<double> Value1Changed;

        /// <summary>
        /// Occurs when value 2 changes.
        /// </summary>
        public event RoutedPropertyChangedEventHandler<double> Value2Changed;

        /// <summary>
        /// Occurs when value modification is started.
        /// </summary>
        public event RoutedEventHandler ValueModificationStarted;

        /// <summary>
        /// Occurs when value modification is finished.
        /// </summary>
        public event RoutedEventHandler ValueModificationFinished;

        /// <summary>
        /// Occurs when value modification is updated.
        /// </summary>
        public event RoutedEventHandler ValueModificationUpdated;

        #endregion

        #region DependencyProperties

        /// <summary>
        /// Identifies the AdvancedSlider.Value1 property.
        /// </summary>
        public static readonly DependencyProperty Value1Property = DependencyProperty.Register("Value1", typeof(double), typeof(AdvancedSlider), new PropertyMetadata(0d, OnValue1PropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.Value2 property.
        /// </summary>
        public static readonly DependencyProperty Value2Property = DependencyProperty.Register("Value2", typeof(double), typeof(AdvancedSlider), new PropertyMetadata(0d, OnValue2PropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.Minimum property.
        /// </summary>
        public static readonly DependencyProperty MinimumProperty = DependencyProperty.Register("Minimum", typeof(double), typeof(AdvancedSlider), new PropertyMetadata(0d, OnMinimumPropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.Maximum property.
        /// </summary>
        public static readonly DependencyProperty MaximumProperty = DependencyProperty.Register("Maximum", typeof(double), typeof(AdvancedSlider), new PropertyMetadata(10d, OnMaximumPropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.TickFrequency property.
        /// </summary>
        public static readonly DependencyProperty TickFrequencyProperty = DependencyProperty.Register("TickFrequency", typeof(double), typeof(AdvancedSlider), new PropertyMetadata(1d, OnTickFrequencyPropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.TickPlacement property.
        /// </summary>
        public static readonly DependencyProperty TickPlacementProperty = DependencyProperty.Register("TickPlacement", typeof(TickPlacement), typeof(AdvancedSlider), new PropertyMetadata(TickPlacement.None));

        /// <summary>
        /// Identifies the AdvancedSlider.IsSnapToTickEnabled property.
        /// </summary>
        public static readonly DependencyProperty IsSnapToTickEnabledProperty = DependencyProperty.Register("IsSnapToTickEnabled", typeof(bool), typeof(AdvancedSlider), new PropertyMetadata(false, OnIsSnapToTickEnabledPropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.SnapTicksToStartFromZero property.
        /// </summary>
        public static readonly DependencyProperty SnapTicksToStartFromZeroProperty = DependencyProperty.Register("SnapTicksToStartFromZero", typeof(bool), typeof(AdvancedSlider), new PropertyMetadata(false, OnSnapTicksToStartFromZeroPropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.IsDragInProgress property.
        /// </summary>
        public static readonly DependencyProperty IsDragInProgressProperty = DependencyProperty.Register("IsDragInProgress", typeof(bool), typeof(AdvancedSlider), new PropertyMetadata(false, OnIsDragInProgressPropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.DimAllOtherThumbsDuringDrag property.
        /// </summary>
        public static readonly DependencyProperty DimAllOtherThumbsDuringDragProperty = DependencyProperty.Register("DimAllOtherThumbsDuringDrag", typeof(bool), typeof(AdvancedSlider), new PropertyMetadata(true));

        /// <summary>
        /// Identifies the AdvancedSlider.DimOpacity property.
        /// </summary>
        public static readonly DependencyProperty DimOpacityProperty = DependencyProperty.Register("DimOpacity", typeof(double), typeof(AdvancedSlider), new PropertyMetadata(0.25));

        /// <summary>
        /// Identifies the AdvancedSlider.RangeVisibility property.
        /// </summary>
        public static readonly DependencyProperty RangeVisibilityProperty = DependencyProperty.Register("RangeVisibility", typeof(Visibility), typeof(AdvancedSlider), new PropertyMetadata(Visibility.Visible));

        /// <summary>
        /// Identifies the AdvancedSlider.ReEvaluateRangeOnValueChanged property.
        /// </summary>
        public static readonly DependencyProperty ReEvaluateRangeOnValueChangedProperty = DependencyProperty.Register("ReEvaluateRangeOnValueChanged", typeof(bool), typeof(AdvancedSlider), new PropertyMetadata(true));

        /// <summary>
        /// Identifies the AdvancedSlider.MinimumValue property.
        /// </summary>
        public static readonly DependencyProperty MinimumValueProperty = DependencyProperty.Register("MinimumValue", typeof(double), typeof(AdvancedSlider), new PropertyMetadata(0d, OnMinimumValuePropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.MaximumValue property.
        /// </summary>
        public static readonly DependencyProperty MaximumValueProperty = DependencyProperty.Register("MaximumValue", typeof(double), typeof(AdvancedSlider), new PropertyMetadata(0d, OnMaximumValuePropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.ValueLabelConverter property.
        /// </summary>
        public static readonly DependencyProperty ValueLabelConverterProperty = DependencyProperty.Register("ValueLabelConverter", typeof(IValueConverter), typeof(AdvancedSlider), new PropertyMetadata(null, OnValueLabelConverterPropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.ValueLabelConverterParameter property.
        /// </summary>
        public static readonly DependencyProperty ValueLabelConverterParameterProperty = DependencyProperty.Register("ValueLabelConverterParameter", typeof(object), typeof(AdvancedSlider), new PropertyMetadata(null));

        /// <summary>
        /// Identifies the AdvancedSlider.AlwaysShowValues property.
        /// </summary>
        public static readonly DependencyProperty AlwaysShowValuesProperty = DependencyProperty.Register("AlwaysShowValues", typeof(bool), typeof(AdvancedSlider));

        /// <summary>
        /// Identifies the AdvancedSlider.AlwaysHideValues property.
        /// </summary>
        public static readonly DependencyProperty AlwaysHideValuesProperty = DependencyProperty.Register("AlwaysHideValues", typeof(bool), typeof(AdvancedSlider));

        /// <summary>
        /// Identifies the AdvancedSlider.Mode property.
        /// </summary>
        public static readonly DependencyProperty ModeProperty = DependencyProperty.Register("Mode", typeof(AdvancedSliderMode), typeof(AdvancedSlider), new PropertyMetadata(AdvancedSliderMode.Range, OnModePropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.AllValueLabelsAtTopWhenVisible property.
        /// </summary>
        public static readonly DependencyProperty AllValueLabelsAtTopWhenVisibleProperty = DependencyProperty.Register("AllValueLabelsAtTopWhenVisible", typeof(bool), typeof(AdvancedSlider), new PropertyMetadata(true, OnAllValueLabelsAtTopWhenVisiblePropertyChanged));

        /// <summary>
        /// Identifies the AdvancedSlider.Ticks property.
        /// </summary>
        public static readonly DependencyProperty TicksProperty = DependencyProperty.Register("Ticks", typeof(DoubleCollection), typeof(AdvancedSlider), new PropertyMetadata(new DoubleCollection()));

        #endregion

        #region Constructors

        /// <summary>
        /// Initializes a new instance of the AdvancedSlider class.
        /// </summary>
        public AdvancedSlider()
        {
            InitializeComponent();
            TimerCallback thumbStoppedMovingCallback = o =>
            {
                thumbStoppedMovingTimer.Change(Timeout.Infinite, Timeout.Infinite);
                if (ValueModificationUpdated != null)
                    Dispatcher.Invoke(() => ValueModificationUpdated.Invoke(this, new RoutedEventArgs()));
            };
            thumbStoppedMovingTimer = new Timer(thumbStoppedMovingCallback, null, Timeout.Infinite, Timeout.Infinite);
            Ticks = GenerateTicks(Minimum, Maximum, SnapTicksToStartFromZero, TickFrequency);
        }

        #endregion

        #region Methods

        /// <summary>
        /// Re-evaluate the Values collection to determine the minimum and maximum values.
        /// </summary>
        public void ReEvaluateValuesForMinimumAndMaximum()
        {
            MinimumValue = Math.Min(Value1, Value2);
            MaximumValue = Math.Max(Value1, Value2);
        }

        /// <summary>
        /// Generate the thumbs for this AdvancedSlider.
        /// </summary>
        protected void GenerateThumbs()
        {
            // pull item control from template
            var trackGrid = (ItemsControl)Slider.Template.FindName("TrackGrid", Slider);

            if (trackGrid == null)
                return;

            // clear all visuals
            trackGrid.Items.Clear();

            // clear tracking
            thumbTrackDictionary.Clear();
            trackValueIndexDictionary.Clear();
            selectedThumb = null;

            // hold margin
            Thickness tickMargin;

            // set margin based on placement
            switch (TickPlacement)
            {
                case (TickPlacement.Both):
                case (TickPlacement.None):
                    tickMargin = new Thickness(0);
                    break;
                case (TickPlacement.BottomRight):
                    tickMargin = new Thickness(5, -2, 6, 0);
                    break;
                case (TickPlacement.TopLeft):
                    tickMargin = new Thickness(5, 0, 6, -2);
                    break;
                default: throw new NotImplementedException();
            }

            // pull tick from template
            var topTick = (TickBar)Slider.Template.FindName("TopTick", Slider);

            if (topTick != null)
                topTick.Margin = tickMargin;

            // pull tick from template
            var bottomTick = (TickBar)Slider.Template.FindName("BottomTick", Slider);

            if (bottomTick != null)
                bottomTick.Margin = tickMargin;

            // pull top and bottom thumb styles
            var topStyle = FindResource("HorizontalTopThumbStyle") as Style;
            Style bottomStyle;

            if (AllValueLabelsAtTopWhenVisible)
                bottomStyle = FindResource("HorizontalBottomThumbStyle") as Style;
            else
                bottomStyle = FindResource("HorizontalBottomThumbStyleLabelAtBottom") as Style;

            var centralStyle = FindResource("CentralThumbStyle") as Style;

            int numberOfThumbs;

            switch (Mode)
            {
                case (AdvancedSliderMode.Range):
                    numberOfThumbs = 2;
                    break;
                case (AdvancedSliderMode.Single):
                    numberOfThumbs = 1;
                    break;
                default: throw new NotImplementedException();
            }

            // create new thumbs
            for (var i = 0; i < numberOfThumbs; i++)
            {
                // create a new track
                var track = new Track
                {
                    Thumb = new Thumb
                    {
                        Style = ((Mode == AdvancedSliderMode.Range) && (i == 0)) ? bottomStyle : (Mode == AdvancedSliderMode.Range) ? topStyle : centralStyle
                    },
                    DecreaseRepeatButton = new RepeatButton { Command = Slider.DecreaseLarge, Opacity = 0, IsHitTestVisible = false },
                    IncreaseRepeatButton = new RepeatButton { Command = Slider.IncreaseLarge, Opacity = 0, IsHitTestVisible = false }
                };

                // handle thumb events
                track.Thumb.DragStarted += Thumb_DragStarted;
                track.Thumb.DragCompleted += Thumb_DragCompleted;
                track.Thumb.DragDelta += Thumb_DragDelta;
                track.PreviewMouseMove += Track_PreviewMouseMove;

                // create minimum binding
                var minimumBinding = new Binding
                {
                    Source = Minimum,
                    Mode = BindingMode.OneWay
                };

                // bind maximum
                var maximumBinding = new Binding
                {
                    Source = Maximum,
                    Mode = BindingMode.OneWay
                };

                // bind value
                var valueBinding = new Binding
                {
                    Source = this,
                    Path = new PropertyPath($"Value{i+1}"),
                    Mode = BindingMode.TwoWay
                };

                // apply all bindings
                track.SetBinding(Track.MinimumProperty, minimumBinding);
                track.SetBinding(Track.MaximumProperty, maximumBinding);
                track.SetBinding(Track.ValueProperty, valueBinding);

                // add to tracking
                trackValueIndexDictionary.Add(track, i);
                thumbTrackDictionary.Add(track.Thumb, track);

                // add to visual
                trackGrid.Items.Add(track);

                // when loaded assign content binding converter
                track.Thumb.Loaded += (s, e) => AssignBindingConverterToThumbLabelContent(s as Thumb, ValueLabelConverter, ValueLabelConverterParameter);
            }

            if (ReEvaluateRangeOnValueChanged)
                ReEvaluateValuesForMinimumAndMaximum();
        }

        /// <summary>
        /// Dim all thumbs that aren't currently selected.
        /// </summary>
        /// <param name="thumbCurrentlySelected">The selected thumb.</param>
        /// <param name="dimOpacity">The dim opacity.</param>
        protected void DimAllNonSelectedThumbs(Thumb thumbCurrentlySelected, double dimOpacity)
        {
            foreach (var thumb in thumbTrackDictionary.Keys)
            {
                if (!Equals(thumb, thumbCurrentlySelected))
                {
                    thumb.Opacity = dimOpacity;
                    thumb.IsHitTestVisible = false;

                    // move unselected to back
                    var track = thumbTrackDictionary[thumb];
                    if (track != null)
                        Panel.SetZIndex(track, 0);
                }
            }

            // bring selected to front
            var selectedTrack = thumbTrackDictionary[thumbCurrentlySelected];
            if (selectedTrack != null)
                Panel.SetZIndex(thumbCurrentlySelected, thumbTrackDictionary.Count);
        }

        /// <summary>
        /// Un-dim all thumbs.
        /// </summary>
        protected void UnDimAllThumbs()
        {
            foreach (var thumb in thumbTrackDictionary.Keys)
            {
                thumb.Opacity = 1;
                thumb.IsHitTestVisible = true;
            }
        }

        /// <summary>
        /// Ensure all values are within the range of this AdvancedSlider.
        /// </summary>
        protected void EnsureAllValuesAreWithinRange()
        {
            if (Value1 < Minimum)
                Value1 = Minimum;

            if (Value1 > Maximum)
                Value1 = Maximum;

            if (Value2 < Minimum)
                Value2 = Minimum;

            if (Value2 > Maximum)
                Value2 = Maximum;
        }

        /// <summary>
        /// Resize the range highlight rectangle.
        /// </summary>
        protected void ResizeRangeHighlights()
        {
            double normalisedMin;
            double normalisedMax;
            Rectangle rangeRectangle;
            Canvas rangeCanvas;

            switch (Mode)
            {
                case (AdvancedSliderMode.Range):
                    // pull rectangle from template
                    rangeRectangle = (Rectangle)Slider.Template.FindName("RangeRectangle", Slider);

                    // pull canvas from template
                    rangeCanvas = (Canvas)Slider.Template.FindName("RangeCanvas", Slider);

                    if ((rangeRectangle == null) || (rangeCanvas == null))
                        return;

                    // return if Minimum or Maximum value is infinity
                    if (double.IsInfinity(MinimumValue) || double.IsInfinity(MaximumValue))
                        return;

                    // normalise in range with support to negative values
                    normalisedMin = (MinimumValue - Minimum) / (Maximum - Minimum);
                    normalisedMax = (MaximumValue - Minimum) / (Maximum - Minimum);

                    switch (Slider.Orientation)
                    {
                        case (Orientation.Horizontal):
                            var trackWidth = rangeCanvas.ActualWidth;
                            Canvas.SetLeft(rangeRectangle, normalisedMin * trackWidth);
                            rangeRectangle.Width = Math.Max(0d, (normalisedMax - normalisedMin) * trackWidth);
                            break;
                        case (Orientation.Vertical):
                            var trackHeight = rangeCanvas.ActualHeight;
                            Canvas.SetTop(rangeRectangle, normalisedMin * trackHeight);
                            rangeRectangle.Height = Math.Max(0d, (normalisedMax - normalisedMin) * trackHeight);
                            break;
                        default: throw new NotImplementedException();
                    }
                    break;
                case (AdvancedSliderMode.Single):
                    // pull rectangle from template
                    rangeRectangle = (Rectangle)Slider.Template.FindName("SingleValueRangeRectangle", Slider);

                    // pull canvas from template
                    rangeCanvas = (Canvas)Slider.Template.FindName("SingleValueRangeCanvas", Slider);

                    if ((rangeRectangle == null) || (rangeCanvas == null))
                        return;

                    // return if Minimum or Maximum value is infinity
                    if (double.IsInfinity(MaximumValue))
                        return;

                    // normalise in range with support to negative values
                    normalisedMin = 0;
                    normalisedMax = (MaximumValue - Minimum) / (Maximum - Minimum);

                    break;
                default:
                    throw new NotImplementedException();
            }

            switch (Slider.Orientation)
            {
                case (Orientation.Horizontal):
                    var trackWidth = rangeCanvas.ActualWidth;
                    Canvas.SetLeft(rangeRectangle, normalisedMin * trackWidth);
                    rangeRectangle.Width = Math.Max(0d, (normalisedMax - normalisedMin) * trackWidth);
                    break;
                case (Orientation.Vertical):
                    var trackHeight = rangeCanvas.ActualHeight;
                    Canvas.SetTop(rangeRectangle, normalisedMin * trackHeight);
                    rangeRectangle.Height = Math.Max(0d, (normalisedMax - normalisedMin) * trackHeight);
                    break;
                default: throw new NotImplementedException();
            }
        }

        /// <summary>
        /// Assign a binding converter to a thumbs value display Label.Content.
        /// </summary>
        /// <param name="thumb">The thumb to update the converter on.</param>
        /// <param name="converter">The converter to assign to the Label.Content binding.</param>
        /// <param name="converterParameter">The converter parameter to assign to the Label.Content binding.</param>
        protected void AssignBindingConverterToThumbLabelContent(Thumb thumb, IValueConverter converter, object converterParameter)
        {
            try
            {
                // get value label from thumb template
                var valueLabel = (Label)thumb.Template.FindName("ValueLabel", thumb);

                if (valueLabel == null)
                    return;

                // use thumb to find track
                Track track = null;

                if (thumbTrackDictionary.ContainsKey(thumb))
                    track = thumbTrackDictionary[thumb];

                if (track == null)
                    return;

                // find index in values
                var index = trackValueIndexDictionary[track];

                var valueBinding = new Binding
                {
                    Source = this,
                    Path = new PropertyPath($"Value{index + 1}"),
                    Mode = BindingMode.OneWay,
                    Converter = converter,
                    ConverterParameter = converterParameter
                };

                valueLabel.SetBinding(ContentProperty, valueBinding);
            }
            catch (Exception e)
            {
                Debug.WriteLine($"Exception caught assigning value converter: {e.Message}");
            }   
        }

        #endregion

        #region StaticMethods

        /// <summary>
        /// Convert a tick frequency to a rounding value.
        /// </summary>
        /// <param name="frequency">The frequency to convert.</param>
        /// <returns>The rounding values.</returns>
        public static int ConvertTickFrequencyToRoundingPlaces(double frequency)
        {
            // based on https://stackoverflow.com/questions/13477689/find-number-of-decimal-places-in-decimal-value-regardless-of-culture
            return BitConverter.GetBytes(decimal.GetBits((decimal)frequency)[3])[2];
        }

        /// <summary>
        /// Generate ticks.
        /// </summary>
        /// <param name="minimum">The minimum value.</param>
        /// <param name="maximum">The maximum value.</param>
        /// <param name="snapTicksToStartFromZero">If ticks are started from zero rather than the minimum value.</param>
        /// <param name="frequency">The frequency of the ticks.</param>
        /// <returns>The ticks.</returns>
        public static DoubleCollection GenerateTicks(double minimum, double maximum, bool snapTicksToStartFromZero, double frequency)
        {
            return GenerateTicks(minimum, maximum, snapTicksToStartFromZero, frequency, ConvertTickFrequencyToRoundingPlaces(frequency));
        }

        /// <summary>
        /// Generate ticks.
        /// </summary>
        /// <param name="minimum">The minimum value.</param>
        /// <param name="maximum">The maximum value.</param>
        /// <param name="snapTicksToStartFromZero">If ticks are started from zero rather than the minimum value.</param>
        /// <param name="frequency">The frequency of the ticks.</param>
        /// <param name="roundingPlaces">The number of decimal places to round to.</param>
        /// <returns>The ticks.</returns>
        public static DoubleCollection GenerateTicks(double minimum, double maximum, bool snapTicksToStartFromZero, double frequency, int roundingPlaces)
        {
            var collection = new DoubleCollection();
            var value = minimum;

            // always add the minimum tick
            collection.Add(value);

            // determine remainder
            var remainder = value - Math.Floor(value / frequency) * frequency;

            // if offsetting the ticks to appear at desired values, and the minimum doesn't fall on one such tick 
            if ((snapTicksToStartFromZero) && (remainder > 0))
            {
                // adjust offset of tick placement
                value -= remainder;
            }
            
            while (value + frequency < maximum)
            {
                value = Math.Round(value + frequency, roundingPlaces);
                collection.Add(value);
            }

            // always add a maximum tick,if not added already
            if (Math.Abs(value - maximum) > 0)
                collection.Add(maximum);

            return collection;
        }

        /// <summary>
        /// Get the next tick value.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <param name="delta">The delta of the change. Numbers greater than 0 will snap to the next positive positive indexed tick, values less than 0 will snap to the next negative indexed tick.</param>
        /// <param name="ticks">The tick collection.</param>
        /// <returns>The next tick value.</returns>
        public static double GetNextTickValue(double value, double delta, DoubleCollection ticks)
        {
            // if found, just return
            if (ticks.Contains(value))
                return value;

            // if a positive delta
            if (delta > 0)
            {
                for (var i = 0; i < ticks.Count; i++)
                {
                    if (value > ticks[i])
                        continue;

                    if (ticks[i] > value)
                        return ticks[i];
                }
            }
            else if (delta < 0)
            {
                // negative delta

                for (var i = ticks.Count - 1; i >= 0; i--)
                {
                    if (value < ticks[i])
                        continue;

                    if (ticks[i] < value)
                        return ticks[i];
                }
            }

            return value;
        }

        #endregion

        #region PropertyChangedCallbacks

        private static void OnIsDragInProgressPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            var inProgress = (bool)e.NewValue;

            if (inProgress)
                control?.ValueModificationStarted?.Invoke(control, new RoutedEventArgs());
            else
                control?.ValueModificationFinished?.Invoke(control, new RoutedEventArgs());
        }

        private static void OnMinimumPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            control.EnsureAllValuesAreWithinRange();
            control.GenerateThumbs();
            control.ReEvaluateValuesForMinimumAndMaximum();
            control.ResizeRangeHighlights();
            control.Ticks = GenerateTicks((double)e.NewValue, control.Maximum, control.SnapTicksToStartFromZero, control.TickFrequency);
        }

        private static void OnMaximumPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            control.EnsureAllValuesAreWithinRange();
            control.GenerateThumbs();
            control.ReEvaluateValuesForMinimumAndMaximum();
            control.ResizeRangeHighlights();
            control.Ticks = GenerateTicks(control.Minimum, (double)e.NewValue, control.SnapTicksToStartFromZero, control.TickFrequency);
        }

        private static void OnMinimumValuePropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;
            control?.ResizeRangeHighlights();
        }

        private static void OnMaximumValuePropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;
            control?.ResizeRangeHighlights();
        }

        private static void OnValue1PropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            var newValue = (double)e.NewValue;

            switch (control.Mode)
            {
                case (AdvancedSliderMode.Range):

                    if ((control.IsDragInProgress) && (newValue > control.Value2))
                    {
                        control.Value1 = control.Value2;
                        return;
                    }

                    break;
            }

            if (control.ReEvaluateRangeOnValueChanged)
                control.ReEvaluateValuesForMinimumAndMaximum();

            control.Value1Changed?.Invoke(control, new RoutedPropertyChangedEventArgs<double>((double)e.OldValue, newValue));
        }

        private static void OnValue2PropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            var newValue = (double)e.NewValue;

            switch (control.Mode)
            {
                case (AdvancedSliderMode.Range):

                    if ((control.IsDragInProgress) && (newValue < control.Value1))
                    {
                        control.Value2 = control.Value1;
                        return;
                    }

                    break;
            }

            if (control.ReEvaluateRangeOnValueChanged)
                control.ReEvaluateValuesForMinimumAndMaximum();

            control.Value2Changed?.Invoke(control, new RoutedPropertyChangedEventArgs<double>((double)e.OldValue, (double)e.NewValue));
        }

        private static void OnValueLabelConverterPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            foreach (var thumb in control.thumbTrackDictionary.Keys)
                control.AssignBindingConverterToThumbLabelContent(thumb, e.NewValue as IValueConverter, ValueLabelConverterParameterProperty);
        }

        private static void OnModePropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            var mode = (AdvancedSliderMode)e.NewValue;

            switch (mode)
            {
                case (AdvancedSliderMode.Single):
                    control.DimAllOtherThumbsDuringDrag = false;
                    break;
                default:
                    break;
            }

            control.GenerateThumbs();
            control.ReEvaluateValuesForMinimumAndMaximum();
            control.ResizeRangeHighlights();
        }

        private static void OnAllValueLabelsAtTopWhenVisiblePropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;
            
            control.GenerateThumbs();
            control.ReEvaluateValuesForMinimumAndMaximum();
            control.ResizeRangeHighlights();
        }

        private static void OnSnapTicksToStartFromZeroPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            control.Ticks = GenerateTicks(control.Minimum, control.Maximum, (bool)e.NewValue, control.TickFrequency);
        }

        private static void OnTickFrequencyPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            control.Ticks = GenerateTicks(control.Minimum, control.Maximum, control.SnapTicksToStartFromZero, (double)e.NewValue);
        }

        private static void OnIsSnapToTickEnabledPropertyChanged(DependencyObject o, DependencyPropertyChangedEventArgs e)
        {
            var control = o as AdvancedSlider;

            if (control == null)
                return;

            if ((bool)e.NewValue)
                control.Ticks = GenerateTicks(control.Minimum, control.Maximum, control.SnapTicksToStartFromZero, control.TickFrequency);
            else
                control.Ticks = new DoubleCollection();
        }

        #endregion

        #region EventHandlers

        private void Slider_OnLoaded(object sender, RoutedEventArgs e)
        {
            GenerateThumbs();
            ReEvaluateValuesForMinimumAndMaximum();
            ResizeRangeHighlights();
        }
        
        private void Thumb_DragStarted(object sender, DragStartedEventArgs e)
        {
            // get selected thumb if it has been clicked only
            var thumb = sender as Thumb;
            if ((selectedThumb == null) && (thumb != null))
            {
                selectedThumb = thumb;
                if (DimAllOtherThumbsDuringDrag)
                    DimAllNonSelectedThumbs(selectedThumb, DimOpacity);

                IsDragInProgress = true;
            }
        }

        private void Thumb_DragCompleted(object sender, DragCompletedEventArgs e)
        {
            thumbStoppedMovingTimer.Change(Timeout.Infinite, Timeout.Infinite);

            // release the thumb
            selectedThumb = null;
            if (DimAllOtherThumbsDuringDrag)
                UnDimAllThumbs();

            if (ReEvaluateRangeOnValueChanged)
                ReEvaluateValuesForMinimumAndMaximum();

            IsDragInProgress = false;
        }

        private void Thumb_DragDelta(object sender, DragDeltaEventArgs e)
        {
            if (ValueModificationUpdated != null)
                thumbStoppedMovingTimer.Change(idleMillisecondsBeforeUpdateTriggerWhileDraggingThumb, Timeout.Infinite);
        }

        private void Track_PreviewMouseMove(object sender, MouseEventArgs e)
        {
            if (selectedThumb != null)
            {
                // get the track the thumb belongs to
                var track = thumbTrackDictionary[selectedThumb];

                // get the index in the values array the track relates to
                var valueIndex = trackValueIndexDictionary[track];

                // get value based on new position, which will move the thumb as it's tracks value is bound to the value in the array
                var value = track.ValueFromPoint(e.GetPosition(track));

                // if snapping to ticks
                if (IsSnapToTickEnabled)
                {
                    // hold old value
                    double oldValue;

                    // determine old value
                    if (valueIndex == 0)
                        oldValue = Value2;
                    else
                        oldValue = Value1;

                    // snap to value
                    value = GetNextTickValue(value, value - oldValue, Slider.Ticks);
                }

                // update value based on new position, which will move the thumb as it's tracks value is bound to the value in the array
                if (valueIndex == 0)
                    Value1 = ((value <= Value2) || (Mode == AdvancedSliderMode.Single)) ? value : Value1;
                else
                    Value2 = ((value >= Value1) || (Mode == AdvancedSliderMode.Single)) ? value : Value2;
            }
        }

        private void RangeCanvas_OnSizeChanged(object sender, SizeChangedEventArgs e)
        {
            ResizeRangeHighlights();
        }

        private void SingleValueRangeCanvas_OnSizeChanged(object sender, SizeChangedEventArgs e)
        {
            ResizeRangeHighlights();
        }

        #endregion

        #region Implementation of IDisposable

        /// <summary>
        /// Performs application-defined tasks associated with freeing, releasing, or resetting unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            thumbStoppedMovingTimer?.Change(Timeout.Infinite, Timeout.Infinite);
            thumbStoppedMovingTimer?.Dispose();
        }

        #endregion
    }
}
